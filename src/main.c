/*!
    \file  main.c
    \brief Empty template for gd32f403 development

    \version 2020-06-10, V0.0.1, firmware for GD32F403
*/

/*

*/

#include "gd32f403.h"
#include "systick.h"
#include <stdio.h>
#include "main.h"

/*!
    \brief      main function
    \param[in]  none
    \param[out] none
    \retval     none
*/

int main(void)
{
    /* configure systick */
    systick_config();

	while (1);
}
