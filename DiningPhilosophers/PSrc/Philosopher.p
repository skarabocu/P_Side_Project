type tPickUpResp = (status: tPickUpRespStatus);

// enum representing the response status for the withdraw request
enum tPickUpRespStatus {
    PICKUP_SUCCESS,
    PICKUP_FAILED
}

event ePickUpResp: tPickUpResp;

machine Philosopher {
    /* tuple of philosopher machines */
    var forkList: (machine, machine);
    var pickedForkNumber : int;

    /* STATES */ 
    start state Init {
        entry (payload : (leftFork: machine, rightFork: machine)) {
            forkList.0 = payload.leftFork;
            forkList.1 = payload.rightFork;

            goto Think;
        }
    }

    state PickedLeftFork {
        entry {
            /* announce */
            /* Try to pick RIGHT fork, for which this philosopher is the LEFT philosopher */
            send forkList.1, eLeftPhilosopherPickUpReq;
        }

        on ePickUpResp do (resp: tPickUpResp) {
            if(resp.status == PICKUP_SUCCESS) {
                goto Eat;
            } else {
                /* announce STUCK */
            }
        }
    }

    state PickedRightFork {
        entry {
            /* announce */
            /* Try to pick LEFT fork, for which this philosopher is the RIGHT philosopher */
            send forkList.0, eRightPhilosopherPickUpReq;
        }

        on ePickUpResp do (resp: tPickUpResp) {
            if(resp.status == PICKUP_SUCCESS) {
                goto Eat;
            } else {
                /* announce STUCK */
            }
        }
    }

    state Eat {
        entry {
            /* announce SUCCESS */

            /* Put down the forks so the other philosopher can eat as well */
            send forkList.0, ePutDownReq;
            send forkList.1, ePutDownReq;
        }
    }

    state Think {
        entry {
            /* announce */
            pickedForkNumber = PickUpRandomFork();
        }

        on ePickUpResp do (resp: tPickUpResp) {
            if(resp.status == PICKUP_SUCCESS) {
                if(pickedForkNumber == 0) goto PickedLeftFork;
                else goto PickedRightFork;
            } else {
                pickedForkNumber = PickUpRandomFork(); 
            }
        }
    }

    /* HELPER FUNCTIONS */
    fun PickUpRandomFork() : int {
        if(choose(2) == 0) {
            /* this philosopher is the RIGHT philosopher for its LEFT fork */
            send forkList.0, eRightPhilosopherPickUpReq;
            return 0;
        } else {
            /* this philosopher is the LEFT philosopher for its RIGHT fork */
            send forkList.1, eLeftPhilosopherPickUpReq;
            return 1;
        }
    } 
}