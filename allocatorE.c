#include <stdlib.h>

#include "allocator.h"
#include "lfl.h"
#include "simpleSet.h"

struct queue {
	Entry *array[ENTRIES_PER_CACHE];
	int h;
};

_Thread_local int current = -1;
_Thread_local struct queue limbo_list[2];
_Thread_local Set hps = NULL;

void init_allocator(struct allocator *allocator, struct localAlloc *lalloc, int numThreads,
    struct DirtyRecord *dirties, int numEntries, int HPsPerThread){
    memset(dirties, 0, numThreads*sizeof(struct DirtyRecord));
//    memset(lalloc, 0, numThreads*sizeof(struct localAlloc));
    threadsDirties=dirties;
//    initAllocator(allocator, sizeof(Entry), numEntries, numThreads, HPsPerThread, dirties, lalloc);
//    for(int i=0; i<numThreads; ++i){
//        initLocalAllocator(&lalloc[i], allocator, i);
//        dirties[i].dirtyNphase=INIT_PHASE<<8;
//    }
}

void retire(ThreadGlobals *tg, void *node){
	if(current == -1){
		limbo_list[0].h = 0;
		limbo_list[1].h = 0;
		current = 0;
	}
	limbo_list[current].array[limbo_list[current].h++] = node;
	if(limbo_list[current].h == ENTRIES_PER_CACHE){
		for(int i = 0; i < tg->input.threadNum; i++){
			threadsDirties[i].dirty = 1;
		}
		__sync_synchronize();
		if(hps)
			setReset(hps);
		else
			hps=setInit(tg->input.threadNum * 3 * 2);
		for(int i = 0; i < tg->input.threadNum; i++){
			Entry *hp0 = threadsDirties[i].HPs[0];
			Entry *hp1 = threadsDirties[i].HPs[1];
			Entry *hp2 = threadsDirties[i].HPs[2];
			if(hp0)
				setAddP(hps, hp0);
			if(hp1)
				setAddP(hps, hp1);
			if(hp2)
				setAddP(hps, hp2);
		}
		for (int i = 0; i < ENTRIES_PER_CACHE; i++){
			if(!setContainsP(hps, limbo_list[current].array[i])){
				free(limbo_list[current].array[i]);
			} else {
				limbo_list[current^1].array[limbo_list[current^1].h++] = limbo_list[current].array[i];
			}
		}
		limbo_list[current].h = 0;
		current ^=1;
	}
}

