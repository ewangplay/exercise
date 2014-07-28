#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/file.h>
#include <sys/mman.h>
#include <sys/wait.h>

void err_and_die(const char * msg)
{
	perror(msg);
	exit(EXIT_FAILURE);
}

int main(int argc, char *argv[])
{
	int ret;
	int fd;
	void *ptr;
	pid_t pid;


	const char * memname = "sample";
	const size_t region_size = sysconf(_SC_PAGE_SIZE);

	/* create new shared memory */
	fd = shm_open(memname, O_CREAT | O_TRUNC | O_RDWR, 0666);
	if(fd == -1)
	{
		err_and_die("shm_open fail!");
	}

	/* set the shared memory size */
	ret = ftruncate(fd, region_size);
	if(ret !=  0)
	{
		err_and_die("ftruncate fail!");
	}

	/* map the shared memory to local address */
	ptr = mmap(0, region_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if(ptr == MAP_FAILED)
	{
		err_and_die("mmap fail!");
	}
	close(fd);

	/* fork child process */
	pid = fork();
	if(pid < 0)
	{
		err_and_die("fork fail!");
	}

	if(pid == 0)	/* child process */
	{
		long * num_ptr = (long *)ptr;
		*num_ptr = 64;
		exit(0);
	}
	else 		/* parent process */
	{
		int status;
		waitpid(pid, &status, 0);
		printf("child process write num: %ld\n", *((long *)ptr));
	}

	/* unmap the shared memory */
	ret = munmap(ptr, region_size);
	if(ret != 0)
	{
		err_and_die("munmap fail!");
	}

	/* remove the shared memory */
	ret = shm_unlink(memname);
	if(ret != 0)
	{
		err_and_die("shm_unlink fail!");
	}

	return 0;
}

