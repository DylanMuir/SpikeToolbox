/* pciaer_stim_mon - C / MEX functionality for stimulating and monitoring spikes
 *                   using the PCI-AER system
 * $Id: pciaer_stim_mon.c 3050 2006-02-06 10:36:18Z dylan $
 */
 
/* Author: Dylan Muir <dylan@ini.phys.ethz.ch>
 * Created: 24th February, 2005 (from stimmon.c)
 * Copyright (c) 2005 Dylan Richard Muir
 */

/* ----- MEX definition */

#if defined(MATLAB_MEX_FILE)
	#define MEX
#endif


/* ----- Includes */

/* - System headers */
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>			/* For stream control	   */
#include <unistd.h>			/* For 'fork()', 'sleep()' */
#include <string.h>			/* For 'strerror()'		   */
#include <sys/errno.h>		/* For strerror(errno)	   */
#include <sys/time.h>		/* For 'gettimeofday()'	   */
#include <sys/wait.h>		/* For 'wait()'			   */
#include <signal.h>			/* For 'signal()'			   */

/* - Semaphore headers */
#include <semaphore.h>
#include <sys/sem.h>
#include <sys/ipc.h>
#include <sys/stat.h>

/* - PCI-AER library headers */
#include <pciaer.h>
#include <pciaerlib.h>

/* - Matlab MEX header and MEX-only headers */
#if defined(MEX)
	#include <mex.h>				/* Matlab mex header file		 */
	#include <sys/shm.h>			/* For shared memory functions */
#endif


/* ----- Macro definitions */

/* -- Macros to split a word into upper and lower bytes */
#define	TOP_HALF(X) ((X) & (~0L << ( 8 * sizeof(X) / 2)))
#define	BOT_HALF(X) ((X) & ~(~0L << ( 8 * sizeof(X) / 2)))


/* ----- Constant definitions */

/* - Function description */
#define	STR_DESCRIPTION	"Stimulate and monitor spike trains using the PCI-AER system"

/* - Command line argument indices */
#define	MIN_IN_ARGS		3
#define	MAX_IN_ARGS		4
#define	MIN_OUT_ARGS	0
#define	MAX_OUT_ARGS	1
#define	ARG_INDEX_COMMAND		0
#define	ARG_INDEX_ISIS			1
#define	ARG_INDEX_STIM_DUR	2
#define	ARG_INDEX_MON_DUR		3
#define	ARG_COMMAND		(argv[ARG_INDEX_COMMAND])
#define	ARG_ISIS			(argv[ARG_INDEX_ISIS])
#define	ARG_STIM_DUR	(argv[ARG_INDEX_STIM_DUR])
#define	ARG_MON_DUR		(argv[ARG_INDEX_MON_DUR])


/* -- Semaphore definitions */
#define	SEM_LOCK_FNAME	"/tmp/stimmon_semaphore_lock"
#define	SEM_STIM_ID		's'
#define	SEM_CLOSE_ID	'c'


/* -- Stimulus and monitoring constants */
#define	PCIAER_MON_BUFFER_SIZE	1000


/* ----- Workhorse function prototypes */

/* -- Timing functions */
void		Tic ();
double	Toc ();

/* - Stimulating and monitoring function */
int	PerformStimMon(pciaer_sequencer_write_ae_t asEvents[], unsigned long ulStimEvents,
							double fStimDuration, double fMonDuration,
							FILE *pfBuffer, unsigned long *pulMonEvents);
int	InitialisePciaer (int *hSeqHandle, int *hMonHandle);
void	ReleasePciaer (int hSeqHandle, int hMonHandle);
int	InitialiseSemaphores (key_t *ktSemStim, int *nSemStim, key_t *ktSemClose, int *nSemClose);
void	ReleaseSemaphores (int nSemStim, int nSemMon);
int	Stimulate (	int hSeqHandle, int nSemStim, int nSemClose,
						pciaer_sequencer_write_ae_t asEvents[], unsigned long ulStimEvents, double fStimDuration);
int	BlockSeqWrite (int hSeqHandle, const pciaer_sequencer_write_ae_t *asEvents, unsigned int nStimEvents,
							int *pnEventsWritten);
int	Monitor (int hMonHandle, key_t ktSemStim, key_t ktSemClose, FILE *pfBuffer, unsigned long *pulMonEvents,
					double fMonDuration);

/* - Signal handler function */
void	SignalHandler (int nSignal);

/* - Global PCI-AER handles */
static int	hSeqHandle = 0,
				hMonHandle = 0;


/* ----- C-mode helper function prototypes */

/* -- These prototypes are only needed in C mode */
#if !defined(MEX)

void	ReadArrayFromFile (	const char *szFileName,
									pciaer_sequencer_write_ae_t *asEvents[], unsigned long *pulStimEvents);

#endif /* !defined(MEX) */



/* ----- MEX-mode helper function prototypes */

/* -- These prototypes are only needed in MEX mode */
#if defined(MEX)

int	TranscribeEventsFromMatlab (	const mxArray *maISIs,
												pciaer_sequencer_write_ae_t *pasEvents[],
												unsigned long *pulStimEvents);
int	TranscribeEventsToMatlab (mxArray *pmaEvents[], FILE *pfBuffer, unsigned long ulMonEvents);

#endif /* defined(MEX) */


/* ----- C-mode entry function */

#if !defined(MEX)		/* function MAIN only exists in non-MEX mode */

int 
main (int argc, char *argv[])
{
	double								fStimDuration, fMonDuration;		/* Stimulus and monitoring duration in ms	   */
	unsigned long						ulStimEvents;							/* Number of events to write					   */
	pciaer_sequencer_write_ae_t	*asEvents;								/* Array containing events in PCI-AER format */

	/* -- Check arguments */
	
	if (argc < MIN_IN_ARGS) {
		/* - Print usage */
		fprintf(stderr, "%s - %s\n%s\n", ARG_COMMAND, STR_DESCRIPTION, "$Id: pciaer_stim_mon.c 3050 2006-02-06 10:36:18Z dylan $");
		fprintf(stderr, "[C BUILD %s - %s %s]\n", PLATFORM, __TIME__, __DATE__);
		fprintf(stderr, "Usage: %s [filename] [stimulus duration (ms)] <[monitoring duration (ms)]>\n", ARG_COMMAND);
		fprintf(stderr, "       Input file format (per line): [inter-spike interval (us)] [tab] [hardware synapse address]\n\n");
		return 0;
	}
	
	/* - Extract stimulus duration, convert to seconds */
	fStimDuration = strtod(ARG_STIM_DUR, NULL) * 1E-3;
	
	/* - Extract monitoring duration, convert to seconds */
	if (argc < ARG_INDEX_MON_DUR+1) {
		/* - Assume monitoring duration == stimulus duration */
		fMonDuration = fStimDuration;
	} else {
		/* - Get monitoring duration from the command line */
		fMonDuration = strtod(ARG_MON_DUR, NULL) * 1E-3;
	}


	/* -- Read array of spikes from the file, if we should stimulate */
	if (fStimDuration > 0) {
		ReadArrayFromFile(ARG_ISIS, &asEvents, &ulStimEvents);
	
		/* - Was there an error? */
		if (ulStimEvents == -1) {
			/* - So bail */
			fprintf(stderr, "Error: Couldn't read event data\n");
			return -1;
		}
	} else {
		asEvents = NULL;
		ulStimEvents = 0;
	}

	/* -- Perform the monitoring and stimulating */
	if (PerformStimMon(asEvents, ulStimEvents, fStimDuration, fMonDuration, stdout, NULL)) {
		fprintf(stderr, "Error: Error during stimulation\n");
		return -1;
	}
	
	/* - Return no error */
	return 0;
}

#endif /* !defined(MEX) */



/* ----- MEX-mode entry function */

#if defined(MEX)		/* function MEXFUNCTION only exists in MEX mode */

/* --- mexFunction - Entry function for MATLAB
 * Usage: [mMonEvents] = pciaer_stim_mon(mStimEvents, fStimDuration <, fMonDuration>)
 * Where: 'mStimEvents' is a matrix containing events to send to the PCI-AER system.
 *        Each row should have the format ['isi'  'address'], where 'isi' is an inter-
 *        spike interval in microseconds, and 'address' is the hardware address of a
 *        synapse to send the event to.  'fStimDuration' and 'fMonDuration' are the
 *        stimulus and monitorin g duration in seconds.
 *        'mMonEvents' will be a matrix containing events read from the PCI-AER
 *        monitor.  Each row will have the format ['timestamp'  'address'], where
 *        'timestamp' is a time stamp in microseconds and 'address' is the hardware
 *        address the event originated from.
 */
void 
mexFunction (int nlhs, mxArray *plhs[],
             int nrhs, const mxArray *prhs[] )
{
	double								fStimDuration,		/* Duration to stimulate in seconds				  */
											fMonDuration;		/* Duration to monitor in seconds				  */
	unsigned long						ulStimEvents;		/* Number of events to write						  */
	pciaer_sequencer_write_ae_t	*asEvents;			/* Array containing events in PCI-AER format	  */
	FILE									*pfBuffer;			/* Temporary stream buffer to monitored events */
	unsigned long						*pulMonEvents;		/* Number of events observed						  */
	int									nSharedSegment;	/* Share memory segment handle					  */


	/* -- Check arguments */
	
	if (nrhs > 3) {
		mexPrintf("--- pciaer_stim_mon: Extra arguments ignored\n");
	}

	if (nrhs < 2) {
		mexPrintf("*** pciaer_stim_mon: Incorrect usage\n");
		mexPrintf("  .MEX file: %s\n  [MEX BUILD %s - %s %s]\n", "$Id: pciaer_stim_mon.c 3050 2006-02-06 10:36:18Z dylan $", PLATFORM, __TIME__, __DATE__);
		mexEvalString("help pciaer_stim_mon");
		return;
	}
	
	/* - Get stimulus duration */
	fStimDuration = mxGetScalar(prhs[ARG_INDEX_STIM_DUR-1]);
	
	/* - Get monitoring duration */
	if (nrhs > 2) {
		fMonDuration = mxGetScalar(prhs[ARG_INDEX_MON_DUR-1]);
		
	} else {	/* Default: same as stimulus duration */
		fMonDuration = fStimDuration;
	}

	/* -- Manage stimulus events */
	if (fStimDuration > 0) {

		/* - Check events matrix size (there should be two columns) */
		if (mxGetN(prhs[ARG_INDEX_ISIS-1]) < 2) {
			mexPrintf("*** pciaer_stim_mon: Too few columns in 'mStimEvents'\n");
			mexEvalString("help pciaer_stim_mon");
			return;
		}

		/* - Transcribe events matrix into asEvents */
		if (TranscribeEventsFromMatlab(prhs[ARG_INDEX_ISIS-1], &asEvents, &ulStimEvents)) {
			mexPrintf("*** pciaer_stim_mon: Could not transcribe events into hardware format\n");
			return;
		}
	} else {
		asEvents = NULL;
		ulStimEvents = 0;
	}
	
	/* - Create temporary stream to buffer monitored events */
	if (!(pfBuffer = tmpfile())) {
		/* - Error creating the temporary buffer */
		mexPrintf("*** pciaer_stim_mon: tmpfile: %s\n", strerror(errno));
		mexPrintf("       Could not create temporary stream buffer\n");
		return;
	}

	/* - Create shared memory segment for pulMonEvents */
	if ((nSharedSegment = shmget(IPC_PRIVATE, sizeof(unsigned long), IPC_CREAT | 0777)) == -1) {
		mexPrintf("*** pciaer_stim_mon: shmget: %s\n", strerror(errno));
		mexPrintf("       Could not create shared memory segment\n");
		return;
	}

	/* - Attach the shared memory */
	if ((int) (pulMonEvents = (unsigned long *) shmat(nSharedSegment, 0, 0)) == -1) {
		mexPrintf("*** pciaer_stim_mon: shmat: %s\n", strerror(errno));
		mexPrintf("       Could not attach shared memory segment\n");
		return;
	}
	
	/* - Perform stimulus and monitoring */
	if (PerformStimMon(asEvents, ulStimEvents, fStimDuration, fMonDuration, pfBuffer, pulMonEvents)) {
		mexPrintf("*** pciaer_stim_mon: Error during stimulation\n");
		return;
	}

	/* - Transcribe events into a matlab array, if there's somewhere to send them */
	if (nlhs > 0) {
		if (TranscribeEventsToMatlab(&(plhs[0]), pfBuffer, *pulMonEvents)) {
			mexPrintf("*** pciaer_stim_mon: Could not transcribe monitored events into matlab format\n");
			return;
		}
	}

	/*  - Close temporary stream buffer */
	fclose(pfBuffer);
	
	/* - Detach shared memory segment (cannot fail) */
	shmdt(pulMonEvents);
	
	/* - Delete shared memory segment */
	if (shmctl(nSharedSegment, IPC_RMID, NULL)) {
		mexPrintf("*** pciaer_stim_mon: shmctl: %s\n", strerror(errno));
		mexPrintf("       Could not delete shared memory segment\n");
		return;
	}
}

#endif /* defined(MEX) */


/* ----- Workhorse functions */

/* -- Timing functions */

static struct timeval	tictime;		/* Global time stamp */


/* --- Tic - Store a starting time stamp
 * Pre: <nul>
 * Post: Current time is stored globally.  Use 'Toc' to retrieve the elapsed time.
 */
void 
Tic ()
{
	/*struct timezone	tv; */
	gettimeofday(&tictime, NULL);
}


/* --- Toc - Return the elapsed time since 'Tic' was called
 * Pre: 'Tic' was called
 * Post: The elapsed time in seconds since 'Tic' was called is returned
 */
double 
Toc ()
{
	struct timeval		toctime;		/* Current time of system clock			   */
	
	/* - Get current time */
	gettimeofday (&toctime, NULL);

	/* - Calculate elapsed seconds */
	toctime.tv_sec -= tictime.tv_sec;
	
	/* - Correct for system tick counter overflow (usec count only) */
	if (toctime.tv_usec < tictime.tv_usec) {
		toctime.tv_usec += 1000000;
		toctime.tv_sec--;
	}
	
	/* - Calculate elapse microseconds */
	toctime.tv_usec -= tictime.tv_usec;
	
	/* - Return elapsed time */
	return (double) toctime.tv_sec + ((double) toctime.tv_usec) / 1E6;
}


/* --- PerformStimMon - Send events to the PCI-AER system and monitor
 * Pre: 'asEvents' is an array of events to send, in [ISI] [address] format
 *      'ulStimEvents' is the number of events to send
 *      'fStimDuration' and 'fMonDuration' are the stimulus and monitoring
 *         durations respectively, in seconds
 *      'pfBuffer' is an open stream handle to use to buffer monitored events
 *      'pulMonEvents' is a pointer to an allocated unsigned long
 * Post: The events in 'anEvents' were written to the PCI-AER system
 *       'pfBuffer' is a rewound stream containing the monitored events
 *       '*pulMonEvents' is the number of events received from the PCI-AER system
 */
int 
PerformStimMon(pciaer_sequencer_write_ae_t asEvents[], unsigned long ulStimEvents,
					double fStimDuration, double fMonDuration,
					FILE *pfBuffer, unsigned long *pulMonEvents)
{
	int	nSemStim, nSemClose;			/* System V semaphores									 */
	key_t	ktSemStim, ktSemClose;		/* Semaphore keys											 */
	pid_t	pidFork;							/* PID returned from fork()							 */

	/* -- Initialise PCI-AER and semaphores */

	/* - Initialise PCI-AER system and obtain handles */
	if (InitialisePciaer(&hSeqHandle, &hMonHandle)) {
		fprintf(stderr, "Error: Could not initialise PCI-AER system\n");
		if (pulMonEvents) *pulMonEvents = -1;
		return -1;
	}
	
	/* - Initialise semaphores */
	if (InitialiseSemaphores(&ktSemStim, &nSemStim, &ktSemClose, &nSemClose)) {
		fprintf(stderr, "Error: Could not initialise semeaphores\n");
		ReleasePciaer(hSeqHandle, hMonHandle);
		if (pulMonEvents) *pulMonEvents = -1;
		return -1;
	}
	
	
	/* -- Fork into stim and mon processes */
	#ifdef PROGRESS
		fprintf(stderr, "Forking...\n");
	#endif
	
	pidFork = fork();
	
	/* - Check fork */
	if (pidFork == -1) {
		/* - Failed! */
		perror("pciaer_stim_mon: PerformStimMon: fork");
		fprintf(stderr, "   Could not fork stimulation and monitoring processes.\n");
		ReleaseSemaphores(nSemStim, nSemClose);
		ReleasePciaer(hSeqHandle, hMonHandle);
		if (pulMonEvents) *pulMonEvents = -1;
		return -1;
	}


	/* -- Assign stimulation and monitoring functions */
	/*    to parent and child processes					  */

	if (pidFork) {
		/* - Parent: Stimulation */
		if (Stimulate(	hSeqHandle,
							nSemStim, nSemClose,
							asEvents, ulStimEvents, fStimDuration)) {
			/* - Stimulation failed */
			fprintf(stderr, "Error: Stimulation failed\n");
		}
		
		/* -- Wait for child termination */
		waitpid(pidFork, NULL, 0);
		
	} else {
		/* - Child: Monitoring */
		if (Monitor(hMonHandle,
						ktSemStim, ktSemClose,
						pfBuffer, pulMonEvents, fMonDuration)) {
			/* - Monitoring failed */
			fprintf(stderr, "Error: Monitoring failed\n");
		}
		
		/* - Child should exit */
		exit(0);
	}
	
	
	/* --- PARENT ONLY		  */
	/* -- Clean up and return */
	
	/* - Clean up */
	ReleaseSemaphores(nSemStim, nSemClose);
	ReleasePciaer(hSeqHandle, hMonHandle);
	
	/* - No errors */
	return 0;
}


/* --- InitialisePciaer - Initialise the PCI-AER system
 * Pre: 'phSeqHandle' and 'phMonHandle' are pointers to allocated integers
 * Post: (Returned 0 && ('*phSeqHandle' contains an open handle to the PCI-AER sequencer) &&
 *                      ('*phSeqHandle' contains an open handle to the PCI-AER sequencer) &&
 *                      The PCI-AER system was initialised sucessfully) ||
 *       (Returned -1 && (Error condition -- must exit))
 */
int 
InitialisePciaer (int *phSeqHandle, int *phMonHandle)
{
	/* -- Attempt to open the sequencer and monitor */
	
	if (PciaerSeqOpen(0, O_RDWR, phSeqHandle) != 0) {
		perror("pciaer_stim_mon: InitialisePciaer: PciaerSeqOpen");
		fprintf(stderr, "   Could not open PCI-AER sequencer\n");
		*phSeqHandle = *phMonHandle = -1;
		return -1;
	}

	if (PciaerMonOpen(0, O_RDWR | O_NONBLOCK, phMonHandle) != 0) {
		perror("pciaer_stim_mon: InitialisePciaer: PciaerMonOpen");
		fprintf(stderr, "   Could not open PCI-AER monitor\n");
		PciaerSeqClose(*phSeqHandle);
		*phSeqHandle = *phMonHandle = -1;
		return -1;
	}


	/* -- Initialise PCI-AER system */
	
	/* - Set monitor counter period to 1 usec */
	if (PciaerSetCounterPeriod(*phMonHandle, 1)) {
		perror("pciaer_stim_mon: InitialisePciaer: PciaerSetCounterPeriod");
		fprintf(stderr, "   Could not set PCI-AER counter period\n");
		PciaerSeqClose(*phSeqHandle);
		PciaerMonClose(*phMonHandle);
		*phSeqHandle = *phMonHandle = -1;
		return -1;
	}
	
	/* - Enable monitor time stamps */
	if (PciaerMonSetTimeLabelFlag(*phMonHandle, 1)) {
		perror("pciaer_stim_mon: InitialisePciaer: PciaerMonSetTimeLabelFlag");
		fprintf(stderr, "   Could not enable time flags on PCI-AER monitor\n");
		PciaerSeqClose(*phSeqHandle);
		PciaerMonClose(*phMonHandle);
		*phSeqHandle = *phMonHandle = -1;
		return -1;
	}

	/* - Reset monitor FIFO */
	if (PciaerResetFifo(*phMonHandle)) {
		perror("pciaer_stim_mon: InitialisePciaer: PciaerResetFifo");
		fprintf(stderr, "   Could not reset PCI-AER monitor FIFO\n");
		PciaerSeqClose(*phSeqHandle);
		PciaerMonClose(*phMonHandle);
		*phSeqHandle = *phMonHandle = -1;
		return -1;
	}
	
	/* - Install signal handler */
	signal(SIGHUP, &SignalHandler);
	signal(SIGINT, &SignalHandler);

	/* - No errors */
	return 0;
}


/* --- InitialiseSemaphores - Create and initialise sempahores
 * Pre: All arguments point to allocated variables
 * Post: (Returned 0 && ('ktSemStim' and 'nSemStim' reference the stimulation semaphore) &&
 *                      ('ktSemClose' and 'nSemClose' reference the termination semaphore) &&
 *                      (Both semaphores are initially unavailable)) ||
 *       (Returned -1 && (Error condition.  Clean up and exit))
 */
int 
InitialiseSemaphores (key_t *pktSemStim, int *pnSemStim, key_t *pktSemClose, int *pnSemClose)
{
	char	szSystemCall[100];		/* Buffer for making a system call */

	/* -- Initialise semaphores used for synchronisation */
	/*    Note: semaphores are initially not available	  */
		
	/* - Ensure the semaphore lock file exists */
	sprintf(szSystemCall, "touch %s", SEM_LOCK_FNAME);
	system(szSystemCall);

	/* - Get semaphore keys */
	*pktSemStim = ftok(SEM_LOCK_FNAME, SEM_STIM_ID);
	*pktSemClose = ftok(SEM_LOCK_FNAME, SEM_CLOSE_ID);
	
	
	/* -- Open semaphores */
	
	/* - Stimulation semaphore */
	*pnSemStim = semget(*pktSemStim, 1, S_IRUSR | S_IWUSR | IPC_CREAT);
		
	if (*pnSemStim == -1) {
   	perror("pciaer_stim_mon: InitialiseSemaphores: setget(ktSemStim)");
   	fprintf(stderr, "   Could not create stimulation semaphore\n");
   	*pnSemStim = *pnSemClose = -1;
   	return -1;
	}
	
	/* - Termination semaphore */
	*pnSemClose = semget(*pktSemClose, 1, S_IRUSR | S_IWUSR | IPC_CREAT);

	if (*pnSemClose == -1) {
  		perror("pciaer_stim_mon: InitialiseSemaphores: setget(ktSemClose)");
  		fprintf(stderr, "   Could not create termination semaphore\n");
   	*pnSemStim = *pnSemClose = -1;
  		return -1;
	}


	/* -- Initialise semaphores */
	
	if (semctl(*pnSemStim, 0, SETVAL, (int) 1) == -1) {
		perror("pciaer_stim_mon: InitialiseSemaphores: semctl(nSemStim)");
		fprintf(stderr, "   Could not initialise stimulation semaphore\n");
   	*pnSemStim = *pnSemClose = -1;
		return -1;
	}

	if (semctl(*pnSemClose, 0, SETVAL, (int) 1) == -1) {
		perror("pciaer_stim_mon: InitialiseSemaphores: semctl(nSemClose)");
		fprintf(stderr, "   Could not initialise termination semaphore\n");
   	*pnSemStim = *pnSemClose = -1;
		return -1;
	}
	
	/* - No errors */
	return 0;
}


/* --- ReleaseSemaphores - Release PCI-AER handles
 * Pre: 'InitialisePciaer()' has been called, 'hSeqHandle' and 'hMonHandle' contain
 *         the values returned from that call
 * Post: The PCI-AER handles have been closed, and the system cleaned up
 */
void 
ReleasePciaer (int hSeqHandle, int hMonHandle)
{
	/* -- Close Pciaer handles */
	
	if (hSeqHandle != -1) PciaerSeqClose(hSeqHandle);
	if (hMonHandle != -1) PciaerMonClose(hMonHandle);
}


/* --- ReleaseSemaphores - Release semaphores and delete lock file
 * Pre: 'InitialiseSemaphores()' has been called, 'nSemStim' and 'nSemClose' contain
 *         the values returned from that call
 * Post: The semaphores are deleted along with the lock file
 */
void 
ReleaseSemaphores (int nSemStim, int nSemClose)
{
	char	szSystemCall[100];

	/* - Release semaphores */
	if (nSemStim != -1) semctl(nSemStim, 0, IPC_RMID);
	if (nSemClose != -1) semctl(nSemClose, 0, IPC_RMID);
	
	/* - Delete lock file */
	sprintf(szSystemCall, "rm %s", SEM_LOCK_FNAME);
	system(szSystemCall);
}


/* --- Stimulate - Send events to the PCI-AER system
 * Pre: 'InitialisePciaer()' and 'InitialiseSemaphres()' have been called sucessfully
 *      'asEvents' is an array of size 'ulStimEvents', containing data to be sent to the sequencer
 * Post: (Returned 0 && (The events were sucessfully sent to the PCI-AER sequencer)) ||
 *       (Returned -1 && (Error sending events - clean up and exit))
 */
int Stimulate (int hSeqHandle, int nSemStim, int nSemClose,
					pciaer_sequencer_write_ae_t asEvents[], unsigned long ulStimEvents, double fStimDuration)
{
	struct sembuf	sbOp;			/* Semaphore operation structure					*/
	int				nWritten;	/* Number of events written to the sequencer */
	
	
	/* -- Wait for the stimulation semaphore, indicating that stimulation should begin */

	/* - Set up a semaphore operation: wait until a semaphore is released */
	sbOp.sem_num = 0;		/* Semaphore 0					 */
	sbOp.sem_op = 0;		/* Wait until it's released */
	sbOp.sem_flg = 0;		/* blocking wait				 */
	
	/* - Wait for the stimulation semaphore */
	if (semop(nSemStim, &sbOp, 1) == -1) {
		perror("pciaer_stim_mon: Stimulate: semop(nSemStim)");
		fprintf(stderr, "   Could not wait for stimuluation semaphore to be released\n");
		return -1;
	}

	
	/* -- Now we're synchronised with the Monitoring process */
	/*    So we can begin stimulating								*/
	
	/* - Display some progress */
	#ifdef PROGRESS
		fprintf(stderr, "Stimulate: Stimulating for [%.2f] seconds\n", fStimDuration);
	#endif
	
	/* - Store the current system time */
	Tic();
	
	/* - Reset PCI-AER system counter */
	if (PciaerResetCounter(hSeqHandle)) {
	   perror("pciaer_stim_mon: Stimulate: PciaerResetCounter");
	   fprintf(stderr, "   Could not reset PCI-AER system counter.\nNot stimulating.\n");
	   return -1;
	}

	if (PciaerResetCounter(hSeqHandle)) {
	   perror("pciaer_stim_mon: Stimulate: PciaerResetCounter");
	   fprintf(stderr, "   Could not reset PCI-AER system counter.\nNot stimulating.\n");
	   return -1;
	}

	if (PciaerResetCounter(hSeqHandle)) {
	   perror("pciaer_stim_mon: Stimulate: PciaerResetCounter");
	   fprintf(stderr, "   Could not reset PCI-AER system counter.\nNot stimulating.\n");
	   return -1;
	}

	/* - Perform blocking write */
	if (BlockSeqWrite(hSeqHandle, asEvents, ulStimEvents, &nWritten)) {
		fprintf(stderr, "Error: Error while stimulating\n");
		return -1;
	}

	/* - Wait to ensure stimulation has completed */
	if (Toc() < fStimDuration) {
		#ifdef PROGRESS
			fprintf(stderr, "Stimulate: Waiting for stimulation to finish...\n");
		#endif
		
		while (Toc() < fStimDuration) {
			sleep(1);
		}
	}
	
	
	/* -- Wait for child to finish monitoring, and return */
	
	#ifdef PROGRESS
		fprintf(stderr, "Stimulate: Waiting for child to finish monitoring...\n");
	#endif
	
	/* - Wait for termination semaphore */
	if (semop(nSemClose, &sbOp, 1) == -1) {
		perror("pciaer_stim_mon: Stimulate: semop(nSemClose)");
		fprintf(stderr, "   Couldn't wait for termination semaphore to be released\n");
		return -1;
	}

	/* - No errors */
	return 0;
}


/* --- BlockSeqWrite - Perform a blocking write of data to the sequencer
 * Pre: 'InitialisePciaer()' has been called sucessfully
 *      'hSeqHandle' is an open handle to the PCI-AER sequencer
 *      'asEvents' is an array of size 'nStimEvents' containing the events to write to the sequencer
 *      'pnEventsWritten' is a pointer to an allocated integer
 * Post: (Returned 0 && ('*pnEventWritten' events from 'asEvents' were written to the sequencer)) ||
 *       (Error condition)
 */
int 
BlockSeqWrite (	int hSeqHandle,
						const pciaer_sequencer_write_ae_t *asEvents, unsigned int nStimEvents,
						int *pnEventsWritten)
{
	unsigned int nRawBufferElements;    /* Number of words currently allocated to the write buffer									   */
	unsigned int *pBufRaw;					/* Pointer to a buffer in which the raw data is prepared										   */
	unsigned int iBufferWord;				/* Index of raw word being written from buffer													   */
	unsigned int nTotalEventsWritten;	/* Running total of the no. of words written updated after each PciaerSeqWriteRaw call */
	unsigned int nEventsInBuffer;       /* Number of events in the raw buffer																   */
	unsigned int nWordsInBuffer;        /* Number of words used in the raw buffer															   */
	unsigned int nWordsWrittenPerCall;	/* No. of words reported as being written by each PciaerSeqWriteRaw call				   */
	unsigned int bNonBlockingExit;      /* BOOL: if true, we're in non-blocking mode and should exit								   */
	int write_return; 				/* Return value from PciaerSeqWriteRaw (error or zero) subsequently used as our return value */
	int prepare_return;         	/* Return value from PrepareRawWriteBuffer																   */

	/* - Our estimate of the required buffer size is two sequencer commands per event */
	/*   This could be reduced as necessary														 */
	nRawBufferElements = 2 * nStimEvents;
    
	/* - We should specify a minimum buffer size */
	if (nRawBufferElements < 128) {
		nRawBufferElements = 128;
	}

	/* -- Allocate buffer in which the raw data is to be prepared */
	pBufRaw = (unsigned int *) malloc (nRawBufferElements * sizeof(unsigned int));
	if (pBufRaw == NULL) {
		*pnEventsWritten = 0;
		return ENOMEM;
	}


	/* -- Write the events to the device (supports NON-BLOCKING) */
	nTotalEventsWritten = 0;
	bNonBlockingExit = 0;
    
	while ((nTotalEventsWritten < nStimEvents) & !bNonBlockingExit) {
		bNonBlockingExit = 0;
    
		/* -- Convert the user-supplied events into a raw buffer */
		prepare_return = PrepareRawWriteBuffer(asEvents + nTotalEventsWritten,
															nStimEvents - nTotalEventsWritten,
															pBufRaw, nRawBufferElements,
															&nEventsInBuffer, &nWordsInBuffer);

		if (prepare_return != 0) {
			/* - Error */
			free (pBufRaw);
			pBufRaw = NULL;
			return prepare_return;
		}
        
		/* -- Check that we could fit at least one event into the buffer */
		if (nEventsInBuffer == 0) {
		/* - Currently this is an error -- in future we could reallocate the buffer */
			free (pBufRaw);
			pBufRaw = NULL;
			return ENOMEM;
		}
		
      /* -- Write the raw buffer to the device    (always BLOCKING) */
      iBufferWord = 0;
      while (iBufferWord < nWordsInBuffer) {
	      write_return = PciaerSeqWriteRaw(hSeqHandle, (signed int *) (pBufRaw + iBufferWord),
	      											nWordsInBuffer - iBufferWord,
	      											&nWordsWrittenPerCall);
           
         /* Check the return value */
         if (write_return != 0) {
			   /* If the 'error' is EAGAIN, this shows that we're in non-blocking mode, and should not */
		      /* continue to loop over events, but it's not an error as such.								 */
		      
		      if (write_return == EAGAIN) {
		      	bNonBlockingExit = 1;
		          
		      } else {		          
		      	/* BUG: In this case, we may have written more events than we say we have, */
		         /*  but at least we won't have written less.  In any case, any error here  */
		         /*  is so severe that it's probably tough luck anyway.						   */
		          
		         free(pBufRaw);
		         pBufRaw = NULL;
		         return write_return;
		      }
		  }
		  
		  /* - Index along the buffer */
		  iBufferWord += nWordsWrittenPerCall;
     }
        
     /* - Record the number of events written so far */
     nTotalEventsWritten += nEventsInBuffer;
     *pnEventsWritten = nTotalEventsWritten;
	}

	/* - Clean up buffer and return */
   free(pBufRaw);
   pBufRaw = NULL;
   return write_return;
}


/* --- Monitor - Monitor events from the PCI-AER system for a specified duration
 * Pre: 'InitialisePciaer()' and 'InitialiseSemaphores()' have been called sucessfully
 *      'hMonHandle' is an open handle to a PCI_AER monitor
 *      'ktSemStim' and 'ktSemClose' are initialised semaphores
 *      'pfBuffer' is a pointer to an open stream
 *      '*pulMonEvents' is an pointer to an allocated unsignedlong
 *      'fMonDuration' is the time in seconds to monitor for
 * Post: 'pfBuffer' will point to a rewound stream containing the monitored events
 *       '*pulMonEvents' will contain the number of monitored events
 */
int 
Monitor (	int hMonHandle,
				key_t ktSemStim, key_t ktSemClose,
				FILE *pfBuffer, unsigned long *pulMonEvents, double fMonDuration)
{
	int								nSemStim, nSemClose;		/* Semaphores									   */
	pciaer_monitor_read_ae_t	*pReadBuf;					/* Read buffer									   */
	unsigned int					nEventsReadPerCall;		/* Number of events read in a single call */
	unsigned long					ulTotalEvents = 0;		/* Total number of read events			   */
	long								read_return;				/* Return value from read call			   */
	unsigned int					nBufIndex;					/* Index into read buffer					   */

	struct sembuf	sbOp;											/* Semaphore operation */

	/* -- Acquire semaphores, set up semaphore operation */
	
	if ((nSemStim = semget(ktSemStim, 0, S_IRUSR | S_IRUSR)) == -1) {
		perror("pciaer_stim_mon: Monitor: semget(ktSemStim)");
		fprintf(stderr, "   Monitor: Could not acquire stimulation semaphore.\n");
		return -1;
	}

	if ((nSemClose = semget(ktSemClose, 0, S_IRUSR | S_IRUSR)) == -1) {
		perror("pciaer_stim_mon: Monitor: semget(ktSemClose)");
		fprintf(stderr, "   Monitor: Could not acquire termination semaphore.\n");
		return -1;
	}
	
	/* - Set up sbOp to decrement a semaphore */
	sbOp.sem_num = 0;		/* Semaphore 0		*/
	sbOp.sem_op = -1;		/* Decrement by 1 */
	sbOp.sem_flg = 0;		/* Unused			*/


	/* -- Allocate read buffer */
	if ((pReadBuf = (pciaer_monitor_read_ae_t *) calloc(PCIAER_MON_BUFFER_SIZE, sizeof(pciaer_monitor_read_ae_t))) == NULL) {
		fprintf(stderr, "Error: Monitor: Could not allocate PCIAER read buffer.\nNOT MONITORING.\n");
				
		/* Allow the parent to stimulate and return */
		semop(nSemStim, &sbOp, 1);
		semop(nSemClose, &sbOp, 1);
		*pulMonEvents = 0;
		return -1;
	}


	/* -- Begin monitoring process */
	
	#ifdef PROGRESS
		fprintf(stderr, "Monitor: Monitoring for [%.2f] sec\n", fMonDuration);
	#endif
	
	/* - Record system timer value */
	Tic();

	/* - Release stimulation semaphore, allow parent to stimulate */
	semop(nSemStim, &sbOp, 1);

	/* - Monitor */
	while (Toc() <fMonDuration) {
		/* - Read a buffer-full of events */
		read_return = PciaerMonRead(hMonHandle, pReadBuf, PCIAER_MON_BUFFER_SIZE, &nEventsReadPerCall);

		if (read_return == 0L) {	/* Successful read */
			/* - Write out buffer to the stream */
			for (nBufIndex = 0; nBufIndex < nEventsReadPerCall; nBufIndex++) {
				/* Mask to 16 bits */
				fprintf(pfBuffer, "%u\t%u\n", pReadBuf[nBufIndex].time_us, pReadBuf[nBufIndex].ae & 0x0000FFFF);
			}
			
			/* - Record total number of events */
			ulTotalEvents += (long) nEventsReadPerCall;
			
		} else {		/* Unsuccessful read, display the error */
			fprintf(stderr, "Monitor: PciaerMonRead error code [%lx]\n", read_return);
			if (TOP_HALF(read_return) == 0)
			    fprintf(stderr, "Monitor: PciaerMonRead: %s\n", strerror(BOT_HALF(read_return)));
			    
			else if (BOT_HALF(read_return) == 0)
			    fprintf(stderr, "Monitor: PciaerMonRead: Hardware error %04x\n", (unsigned int) TOP_HALF(read_return));
			    
			else
			    fprintf(stderr, "Monitor: PciaerMonRead: Protocol error %ld\n", read_return);
		}
	}

	/* - Display some progress */
	#ifdef PROGRESS
		fprintf(stderr, "Monitor: Finished monitoring.\n");
		fprintf(stderr, "Monitor: Recieved %lu spikes from device.\n", ulTotalEvents);
	#endif

	/* - Allow the parent to terminate and close handles */
	semop(nSemClose, &sbOp, 1);

	/* - Send back the number of written events */
	if (pulMonEvents) *pulMonEvents = ulTotalEvents;
	
	/* - Rewind buffer stream */
	rewind(pfBuffer);
	
	/* - No errors */
	return 0;
}

/* --- SignalHandler - Signal handling function to clean up
 * Pre: 
 */
void 
SignalHandler (int nSignal)
{
	/* - Release the PCI-AER system handles */
	ReleasePciaer(hSeqHandle, hMonHandle);
}


/* ----- C-mode helper functions */

/* -- Only compile these functions if we're in C mode */
#if !defined(MEX)


/* ReadArrayFromFile - Read an array from a file
 * Pre: 'szFileName' contains the name of the file to try to read from
 *      'anEvents' is a pointer to an unallocated array to return the data in
 *      'pulSize' is a pointer to an allocated unsigned long integer
 * Post: '*pulSize' will contain the number of rows read from the file
 *       'anEvents' will contain the data read from the file
 *       If an error occurred, 'nSize' will be -1
 */
void 
ReadArrayFromFile (const char *szFileName, pciaer_sequencer_write_ae_t *asEvents[], unsigned long *pulSize)
{
	FILE	*pfFile = NULL;				/* File handle				  */
 	unsigned long	nPatternIndex,		/* Index into spike array */
 						nAddress,			/* Current address		  */
 						nInterval;			/* Current ISI				  */

  	/* -- Attempt to open the file */
  	if (!(pfFile = fopen(szFileName, "r"))) {
  		/* - Couldn't open the file, so print an error and return */
  		perror("pciaer_stim_mon: ReadArrayFromFile: open");
  		fprintf(stderr, "   File [%s] could not be opened for reading\n", szFileName);
  		*pulSize = -1;
  		return;
  	}

	/* -- Count the number of patterns in the file */
	
	*pulSize = 0;

	while (fscanf(pfFile, "%lu\t%lu\n", &nInterval, &nAddress) != EOF) {
		(*pulSize)++;
	}
	
	/* -- Rewind file and read events */
	
	rewind(pfFile);

	/* - Print some progress, if required */
	#ifdef PROGRESS
		fprintf(stderr, "Reading %lu spike events total from file\n", *pulSize);
	#endif
	
	/* - Allocate data array */
	if (!(*asEvents = (pciaer_sequencer_write_ae_t *) malloc(sizeof(pciaer_sequencer_write_ae_t) * *pulSize))) {
		/* - Couldn't allocate the array */
		perror("pciaer_stim_mon: ReadArrayFromFile: malloc");
		fprintf(stderr, "   Could not allocate stimulus array\n");
		fclose(pfFile);
		*pulSize = -1;
		return;
	}
	
	/* - Read patterns */
	nPatternIndex = 0;
	while (fscanf(pfFile, "%lu\t%lu\n", &nInterval, &nAddress) != EOF) {
		(*asEvents)[nPatternIndex].isi_us = nInterval;
		(*asEvents)[nPatternIndex].ae = nAddress;
		
  		nPatternIndex++;
  	}

	/* - Close the input file */
  fclose(pfFile);
}


#endif /* !defined(MEX) */



/* ----- MEX-mode helper functions */

/* -- Only compile these functions if we're in MEX mode */
#if defined(MEX)

/* --- TranscribeEventsFromMatlab - Transcribe events from matlab into hardware format
 * Pre: 'maISIs' is a matlab array containing the event data.  The first column is
 *      the ISI in microseconds, the second column is the hardware address.
 *      'pasEvents' is a pointer to an unallocated array.
 *      'pulStimEvents' is a pointer to an allocated unsigned long integer.
 * Post: (Returned 0 && ('pasEvents' will be a pointer to an allocated array of size
 *       '*pulStimEvents', containing the events from 'maISIs')) ||
 *       (Returned -1 && (Error condition.  Clean up and terminate.))
 */
int 
TranscribeEventsFromMatlab (const mxArray *maISIs, pciaer_sequencer_write_ae_t *pasEvents[], unsigned long *pulStimEvents)
{
	unsigned long	ulEventIndex;			/* Index into events array	 */
	double			*daAddress,				/* Address event data array */
						*daInterval;			/* ISI event data array		 */

	/* - Determine number of events total */
	*pulStimEvents = mxGetM(maISIs);
	
	/* - Allocate events array to return */
	if (!(*pasEvents = (pciaer_sequencer_write_ae_t *) malloc(sizeof(pciaer_sequencer_write_ae_t) * *pulStimEvents))) {
		mexPrintf("*** pciaer_stim_mon: TranscribeEvents: malloc: %s", strerror(errno));
		mexPrintf("       Could not allocate hardware events array\n");
		return -1;
	}
	
	/* - Get event data array */
	daInterval = mxGetPr(maISIs);
	daAddress = daInterval + *pulStimEvents;
	
	/* - Transcribe events */
	for (ulEventIndex = 0; ulEventIndex < *pulStimEvents; ulEventIndex++) {
		(*pasEvents)[ulEventIndex].isi_us = daInterval[ulEventIndex];
		(*pasEvents)[ulEventIndex].ae =  daAddress[ulEventIndex];
	}
	
	/* - No errors */
	return 0;
}


/* --- TranscribeEventsToMatlab - Copy events from a buffer into a matlab array
 * Pre: 'pmaEvents' points to an unallocated mxArray
 *      'pfBuffer' points to a rewound stream containing the events in the format
 *      ['timestamp'] [tab] ['address'], where 'timestamp' is a timestamp in microseconds
 *      and 'address' is a PCI-AER hardware address
 *      'ulMonEvents' contains the number of events in the stream
 * Post: (Returned 0 && ('*pmaEvents' points to an allocated mxArray) &&
 *                      (The events from 'pfBuffer' were copied into '*pmaEvents')) ||
 *       (Returned -1 && (Error condition.  The events were not copied))
 */
int 
TranscribeEventsToMatlab (mxArray *pmaEvents[], FILE *pfBuffer, unsigned long ulMonEvents)
{
	double			*daTimestamps,		/* Timestamp data array			*/
						*daAddresses;		/* Address data array			*/
	unsigned long	ulEventIndex,		/* Index into events array		*/
						ulTimestamp,		/* \_ Values read from buffer */
						ulAddress;			/* /									*/


	/* - Create matlab array */
	if (!(*pmaEvents = mxCreateDoubleMatrix(ulMonEvents, 2, mxREAL))) {
		/* - Error: won't ever reach here if executed from Matlab */
		mexPrintf("*** pciaer_stim_mon: TranscribeEventsToMatlab: mxCreateDoubleMatrix\n");
		mexPrintf("       Couldn't allocate return events array\n");
		return -1;
	}

	/* -  Get data pointers */
	daTimestamps = mxGetPr(*pmaEvents);
	daAddresses = daTimestamps + ulMonEvents;

	/* - Copy events */
	for (ulEventIndex = 0; ulEventIndex < ulMonEvents; ulEventIndex++) {
		fscanf(pfBuffer, "%lu\t%lu\n", &ulTimestamp, &ulAddress);
		daTimestamps[ulEventIndex] = ulTimestamp;
		daAddresses[ulEventIndex] = ulAddress;
	}

	/* - No errors */
	return 0;
}

# endif /* defined(MEX) */

/* --- END of pciaer_stim_mon.c --- */
