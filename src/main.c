/*******************************************************************************
  Main Source File

  Company: Microchip Technology Inc.

  File Name: main.c

  Summary: This file contains the "main" function for a project.

  Description:
    This file is a template for implementing a SensiML knowledge pack. It
    implements all stubs required by the SensiML SDK.
 *******************************************************************************/

// *****************************************************************************
// *****************************************************************************
// Section: Included Files
// *****************************************************************************
// *****************************************************************************

#include <xc.h>
#include <stdlib.h>                     // Defines EXIT_FAILURE
#include "kb.h"
#include "kb_typedefs.h"

// *****************************************************************************
// *****************************************************************************
// Section: SensiML stub definitions
// *****************************************************************************
// *****************************************************************************

void init_model(void)
{
    kb_model_init();
}

/*
* This function implements inferencing for a single model knowledgepack. Visit
* the SensiML documentation to learn how to implement more complex models:
* https://sensiml.com/documentation/knowledge-packs/building-a-knowledge-pack-library.html#calling-knowledge-pack-apis-from-your-code
*/
#define KB_MODEL_Parent_INDEX 0
int run_model(SENSOR_DATA_T *data, int nsensors)
{
    int ret;

    ret = kb_run_model((SENSOR_DATA_T *) data, nsensors, KB_MODEL_Parent_INDEX);
    if (ret >= 0) {
        kb_reset_model(0);
    };

    return ret;
}

SENSOR_DATA_T read_sample(void)
{
    /* Implement signal data retrieval routine */
    return 0;
}

// *****************************************************************************
// *****************************************************************************
// Section: Main Entry Point
// *****************************************************************************
// *****************************************************************************
#define SENSOR_NUM_AXES 0

void main(void)
{
    /* Initialize SensiML Knowledge Pack */
    init_model();

    int class_id = 0;
    while (1) {
        /* Read a sensor sample */
        SENSOR_DATA_T x = read_sample();

        /* Feed sample into the SensiML API */
        int ret = run_model(&x, SENSOR_NUM_AXES);

        /* Act on classification */
        if (ret == 0) {
            // Unknown class
            class_id = ret;
        }
        else if (ret > 0) {
            // One of the known classes
            class_id = ret;
        }
        // else {
        //     // No classification yet
        // }
    }

    return ( EXIT_FAILURE );
}
