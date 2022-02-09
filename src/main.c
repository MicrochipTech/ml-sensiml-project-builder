/*******************************************************************************
  Main Source File

  Company: Microchip Technology Inc.

  File Name: main.c

  Summary: This file contains the "main" function for a project.

  Description:
    This file is a template for implementing a SensiML knowledge pack. It
    implements all stubs required by the Edge Impulse SDK.
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

void sml_model_init(void)
{
    kb_model_init();
}

int sml_recognition_run(SENSOR_DATA_T *data, int nsensors)
{
    int ret;
    ret = kb_run_model((SENSOR_DATA_T *) data, nsensors, 0);
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
    sml_model_init();

    int class_id = 0;
    while (1) {
        /* Read a sensor sample */
        SENSOR_DATA_T x = read_sample();

        /* Feed sample into the SensiML API */
        int ret = sml_recognition_run(&x, SENSOR_NUM_AXES);

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
