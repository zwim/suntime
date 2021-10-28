
// modified to take arguments by zwim
// 2021-10-20

// Original can be found on https://midcdmz.nrel.gov/spa/
// Additional the two files spa.c spa.h have to be downloaded from there.


// usage: spa latitude longitude year month day timezone pr
//            if pr==0 details are printed
//            else only date, sunrise and sunset are printed

/////////////////////////////////////////////
//          SPA TESTER for SPA.C           //
//                                         //
//      Solar Position Algorithm (SPA)     //
//                   for                   //
//        Solar Radiation Application      //
//                                         //
//             August 12, 2004             //
//                                         //
//   Filename: SPA_TESTER.C                //
//                                         //
//   Afshin Michael Andreas                //
//   afshin_andreas@nrel.gov (303)384-6383 //
//                                         //
//   Measurement & Instrumentation Team    //
//   Solar Radiation Research Laboratory   //
//   National Renewable Energy Laboratory  //
//   1617 Cole Blvd, Golden, CO 80401      //
/////////////////////////////////////////////

/////////////////////////////////////////////
// This sample program shows how to use    //
//    the SPA.C code.                      //
/////////////////////////////////////////////

#include <stdio.h>
#include <stdlib.h>
#include "spa.h"  //include the SPA header file

int do_spa(double latitude, double longitude, int y, int m, int d, int tz, int pr);

int main (int argc, char *argv[])
{
    if (argc > 6)
        return do_spa(atof(argv[1]), atof(argv[2]),
            atoi(argv[3]), atoi(argv[4]), atoi(argv[5]), atoi(argv[6]), atoi(argv[7]));
    else
        return do_spa(47.25786, 11.35111, 2021, 1, 17, 2, 1);
}



int do_spa(double latitude, double longitude, int y, int m, int d, int tz, int pr)
{
    spa_data spa;  //declare the SPA structure
    int result;
    float min, sec;

    //enter required input values into SPA structure

    spa.year          = y; //2021; //2003;
    spa.month         = m; //10; //10;
    spa.day           = d; //17; //17;
    spa.hour          = 12;
    spa.minute        = 00;
    spa.second        = 00;
    spa.timezone      = tz; //2.0; //-7.0;
    spa.delta_ut1     = 0;
    spa.delta_t       = 0; //67;
    spa.longitude     = longitude; //11.35111; //12.09; //-105.1786;
    spa.latitude      = latitude; //47.25786; // 47.51; //39.742476;
    spa.elevation     = 520; //1830.14;
    spa.pressure      = 941; //820;
    spa.temperature   = 11; //11;
    spa.slope         = 30;
    spa.azm_rotation  = -10;
    spa.atmos_refract = 0.5667;
    spa.function      = SPA_ALL;

    //call the SPA calculate function and pass the SPA structure

    result = spa_calculate(&spa);

    if (result == 0)  //check for SPA errors
    {
        if ( pr == 0 )
        {
            printf("%4d.%2d.%2d\n", y, m, d);

            //display the results inside the SPA structure
            printf("Julian Day:    %.6f\n",spa.jd);
            printf("L:             %.6e degrees\n",spa.l);
            printf("B:             %.6e degrees\n",spa.b);
            printf("R:             %.6f AU\n",spa.r);
            printf("H:             %.6f degrees\n",spa.h);
            printf("Delta Psi:     %.6e degrees\n",spa.del_psi);
            printf("Delta Epsilon: %.6e degrees\n",spa.del_epsilon);
            printf("Epsilon:       %.6f degrees\n",spa.epsilon);
            printf("Zenith:        %.6f degrees\n",spa.zenith);
            printf("Azimuth:       %.6f degrees\n",spa.azimuth);
            printf("Incidence:     %.6f degrees\n",spa.incidence);

            min = 60.0*(spa.sunrise - (int)(spa.sunrise));
            sec = 60.0*(min - (int)min);
            printf("Sunrise:       %02d:%02d:%02d Local Time\n", (int)(spa.sunrise), (int)min, (int)sec);

            min = 60.0*(spa.sunset - (int)(spa.sunset));
            sec = 60.0*(min - (int)min);
            printf("Sunset:        %02d:%02d:%02d Local Time\n", (int)(spa.sunset), (int)min, (int)sec);
        }
        else
        {
            printf("spa: %d.%d.%d\t",y, m, d);
            min = 60.0*(spa.sunrise - (int)(spa.sunrise));
            sec = 60.0*(min - (int)min);
            printf("spa.rise %02d:%02d:%02d\t", (int)(spa.sunrise), (int)min, (int)sec);

            min = 60.0*(spa.sunset - (int)(spa.sunset));
            sec = 60.0*(min - (int)min);
            printf("spa.set %02d:%02d:%02d\t", (int)(spa.sunset), (int)min, (int)sec);

//            printf("  zgl:\t%02f", spa.eot);

//            printf("\n");
        }
    } else printf("SPA Error Code: %d\n", result);

    return 0;
}

/////////////////////////////////////////////
// The output of this program should be:
//
//Julian Day:    2452930.312847
//L:             2.401826e+01 degrees
//B:             -1.011219e-04 degrees
//R:             0.996542 AU
//H:             11.105902 degrees
//Delta Psi:     -3.998404e-03 degrees
//Delta Epsilon: 1.666568e-03 degrees
//Epsilon:       23.440465 degrees
//Zenith:        50.111622 degrees
//Azimuth:       194.340241 degrees
//Incidence:     25.187000 degrees
//Sunrise:       06:12:43 Local Time
//Sunset:        17:20:19 Local Time
//
/////////////////////////////////////////////

