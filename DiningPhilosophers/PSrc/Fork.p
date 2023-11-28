/* Events used by the philosopher to interact with the Fork */
event eLeftPhilosopherPickUpReq;
event eRightPhilosopherPickUpReq;
event ePutDownReq;

// enum to represent the state of the fork
enum tForkState 
    {
        PickedUp,
        PutDown
    }

machine Fork 
    {
        /* tuple of philosopher machines */
        var philosopherList: (machine, machine);
        /* 0 - left philosopher ; 1 - right philosopher ; -1 - default */
        var currentHolder: int;

        /* STATES */ 

        start state Init {
            entry (payload : (leftPhilosopher: machine, rightPhilosopher: machine)) {
            philosopherList.0 = payload.leftPhilosopher;
            philosopherList.1 = payload.rightPhilosopher;
            goto PutDownFork;
            }
        }

        state PickedUpFork {
            entry {
                /* announce */ 
            }

            on ePutDownReq goto PutDownFork; 

            on eLeftPhilosopherPickUpReq do {
                ResponseWhilePickedUp(0, currentHolder);
            }

            on eRightPhilosopherPickUpReq do {
                ResponseWhilePickedUp(1, currentHolder);
            }
        }

        state PutDownFork {
            entry {
                /* announce */
                currentHolder = -1;
                WaitForPhilosopher();
                goto PickedUpFork; 
            }
        }

        /* HELPER FUNCTIONS */ 

        // block until a user shows up
        fun WaitForPhilosopher() {
            var response: tPickUpResp;
            response.status =  PICKUP_SUCCESS;
                    
            receive {
                case eLeftPhilosopherPickUpReq: {
                    currentHolder = 0;
                    send philosopherList.0, ePickUpResp, response;
                }
                case eRightPhilosopherPickUpReq: {
                    currentHolder = 1;
                    send philosopherList.1, ePickUpResp, response;
                }
            }
        }

        // either reject the request or print doublePickUp request error
        fun ResponseWhilePickedUp(requester: int, holder: int) {
            var response: tPickUpResp;
            response.status =  PICKUP_FAILED;

            if(holder == requester) {
                /* announce doublePickUp request from same philosopher */
                print "The left philosopher tried to pick up the same fork!";
            } else if(requester == 0) {
                send philosopherList.0, ePickUpResp, response;
            } else {
                send philosopherList.1, ePickUpResp, response;
            }
        }
    }