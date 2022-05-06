![https://www.microchip.com/](assets/microchip.png)
# SensiML Project Builder


# Contents
<!-- no toc -->
- [Overview](#overview)
- [Knowledge Pack Deployment](#knowledge-pack-deployment)
- [Knowledge Pack Compilation](#knowledge-pack-compilation)
- [Knowledge Pack Integration](#knowledge-pack-integration)

# Overview
This repository contains instructions for creating a library object from a
[SensiML Analytics Studio](https://sensiml.com/products/analytics-studio/)
project deployment for any xc8, xc16, or xc32 supported platform.

## Usage Notes

- If you plan on running `build.sh` from a Windows machine you will require [Git
  Bash](https://gitforwindows.org/).
- `*.options.ini` can be modified to set additional project options; for help
  call the MPLAB script `prjMakefilesGenerator -setoptions=@ -help`
  + NB: all relative paths are considered relative to the project root folder
    (.X folder)
- `*.project.ini` is just a placeholder - the **languageToolchain** and
  **device** variables are replaced when building the project - others will take
  default values if unspecified.

## Software Used
* MPLAB® X IDE *>=6.00* (https://microchip.com/mplab/mplab-x-ide)

# Knowledge Pack Deployment
To deploy a knowledge pack from the SensiML Analytics Studio:

1. Open up your SensiML project in the [Analytics Studio](https://app.sensiml.cloud/) and navigate to the *Download Model* tab.
2. Select `Microchip SAMD21 ML Eval Kit` from the *HW Platform* options.
   - *Although SAMD21 ML Eval Kit is specified as the hardware platform, the
   resulting source code should be compatible with any Microchip platform.*
3. Select one of *Binary*, *Library* or *Source* from the *Format* options.
   - *Source format is only available for upper tier SensiML customers*.
4. Select the appropriate sensor configuration for your project from the *Data
   Source* options.

   - *Note that this configuration should match the one you used to capture the
   data your model was trained with.*

   - *This step is only relevant for the SAMD21 ML Eval Kit - in all other cases
   you will have to manually verify your sensor configuration*
5. Click the *Download* button to download the model.

   | ![https://www.microchip.com/](assets/deployment.jpeg) |
   | :--: |
   | Deployment from the Analytics Studio |

# Knowledge Pack Compilation

The following steps cover compiling the SensiML source code into a static
library object.

## Using `build.sh`

1. Extract the library archive from the step above directly into this folder.
   The zip file should contain a folder named `knowledgepack` where all the
   SensiML source code is located.

2. (Optional) Open `options.ini` and modify as needed.

3. Set the environment variables `MPLABX_VERSION XC_NUMBER_BITS XC_VERSION` as
   desired, then run `build.sh` to generate the library object. For example:

   `MPLABX_VERSION=6.00 XC_VERSION=4.00 XC_NUMBER_BITS=32 ./build.sh ATSAME54P20A libsensiml .`

   If MPLAB and/or XC versions are unspecified, the program will select the
   latest versions found on your system in the default install locations. If
   MPLAB X or the XC compiler are in non-default install locations, you can
   manually set the corresponding path directly through the `MPLABX_PATH` and
   `XC_PATH` environment variables.

4. See the [integration instructions](#integration-instructions) below to
   integrate the library with your MPLAB X project.

## Using Docker

For convenience, `docker_build.sh` is provided which contains a full example for
building the docker image and generating the SensiML library/project. This
script can be run by passing the target name and the corresponding .args file e.g.:

```bash
./docker_build.sh ATSAME54P20A args/SAME54.args
```

The output of the build process will be placed in a folder named `dist/` under
your current working directory.

Note: The `.args` files included in this repository may not always be up to
date. Check
[packs.download.microchip.com](https://packs.download.microchip.com/) for the
most up to date device family pack listings.

# Knowledge Pack Integration
Below are instructions for integrating the library object, compiled with the
steps above, into an MPLAB X project.

1. Add the library object from the step above into an existing MPLAB project as
   shown below.

   ![Add library object](assets/addlibrary.png)

2. Extract the SensiML deployment archive somewhere into your project
   directory.

3. Add the path to the `inc` folder from the SensiML deployment archive (e.g.
   `../knowledgepack/sensiml/inc`) into your include path under *Project
   Properties* -> *xc32/16/8-gcc* -> *Preprocessing and messages* -> *Common
   include dirs*

   ![Add include directory](assets/include.png)

4. Ensure that the `Remove unused sections` option under *Project Properties* ->
   *xc32-ld* is enabled (option is shown in the image below); this will
   eliminate any unused data or functions from the SDK to reclaim device memory.

   ![Add include directory](assets/linker.png)

5. Use `src/main.c` as a template for integrating the SensiML library
   into your project.

You should now have your SensiML model fully integrated with an MPLAB X project.
In order to update the deployed model, simply repeat the steps from the [build
instructions](#sensiml-sdk-build-instructions) section above.

