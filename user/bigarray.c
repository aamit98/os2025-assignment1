// user/bigarray.c
#include "user.h"

#define NUM_CHILDREN 4

int
main(int argc, char *argv[])
{
  int arrsize = 1 << 16; // 65536 elements
  static int arr[65536]; // static to keep it off the stack

  // Initialize the array with consecutive numbers 0..65535.
  for (int i = 0; i < arrsize; i++) {
    arr[i] = i;
  }

  // Create 4 child processes using the custom forkn system call.
  int pids[NUM_CHILDREN];
  int r = forkn(NUM_CHILDREN, pids);
  if (r == -1) {
    printf("forkn failed!\n");
    exit(1, "");
  }

  if (r > 0) {
    // Child process branch:
    // In each child, forkn returns a unique number in 1..NUM_CHILDREN.
    int idx = r - 1;  // Convert child number (1..NUM_CHILDREN) to index 0..NUM_CHILDREN-1.
    int start = idx * (arrsize / NUM_CHILDREN);
    int end   = start + (arrsize / NUM_CHILDREN);
    long partialSum = 0;
    for (int i = start; i < end; i++) {
      partialSum += arr[i];
    }
    // Exit with the computed partial sum as the exit status.
    exit((int)partialSum, "");
  } else {
    // Parent process branch (forkn returns 0 in the parent).
    // Print the child PIDs.
    for (int i = 0; i < NUM_CHILDREN; i++) {
      printf("Child #%d has pid=%d\n", i + 1, pids[i]);
    }

    // Wait for all children to finish and retrieve their exit statuses.
    int totalChildren;
    int statuses[64]; // Array large enough for all children.
    if (waitall(&totalChildren, statuses) < 0) {
      printf("waitall failed!\n");
      exit(1, "");
    }
    if (totalChildren != NUM_CHILDREN) {
      printf("Error: expected %d children, got %d\n", NUM_CHILDREN, totalChildren);
      exit(1, "");
    }
    
    // Sum the partial sums from each child.
    long finalSum = 0;
    for (int i = 0; i < NUM_CHILDREN; i++) {
      printf("Child %d exit status = %d\n", i + 1, statuses[i]);
      finalSum += statuses[i];
    }
    printf("All children done. Final sum = %d\n", finalSum);
    exit(0, "Done with bigarray");
  }
  exit(1, "unexpected");
}
