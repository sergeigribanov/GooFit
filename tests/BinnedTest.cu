#include "gtest/gtest.h"

#include "goofit/FitManager.h"
#include "goofit/BinnedDataSet.h"
#include "goofit/PDFs/ExpPdf.h"
#include "goofit/PDFs/ProdPdf.h"

#include "goofit/Variable.h"

#include <sys/time.h>
#include <sys/times.h>
#include <iostream>

#include <random>


TEST(BinnedFit, SimpleFit) {
    
    // Random number generation
    std::mt19937 gen(137);
    std::exponential_distribution<> d(1.5);
    
    // Independent variable.
    Variable xvar{"xvar", 0, 10};
    
    // Data set
    BinnedDataSet data(&xvar);
    
    // Generate toy events.
    for(int i=0; i<100000; ++i) {
        double val = d(gen);
        if(val < 10) {
            xvar.value = val;
            data.addEvent();
        }
    }
    
    // Fit parameter
    Variable alpha{"alpha", -2, 0.1, -10, 10};
    
    // GooPdf object
    ExpPdf exppdf{"exppdf", &xvar, &alpha};
    exppdf.setData(&data);
    
    FitManager fitter{&exppdf};
    fitter.fit();
    
    EXPECT_TRUE(fitter);
    EXPECT_LT(alpha.error, .01);
    EXPECT_NEAR(-1.5, alpha.value, alpha.error*3);
}


TEST(BinnedFit, DualFit) {
    
    // Random number generation
    std::mt19937 gen(137);
    std::exponential_distribution<> dx(1.5);
    std::exponential_distribution<> dy(.75);
    
    // Independent variable.
    Variable xvar{"xvar", 0, 10};
    Variable yvar{"yvar", 0, 10};
    
    // Data set
    BinnedDataSet data {{&xvar, &yvar}};
    
    // Generate toy events.
    for(int i=0; i<200000; ++i) {
        double xval = dx(gen);
        double yval = dy(gen);
        if(xval < 10 && yval < 10) {
            xvar.value = xval;
            yvar.value = yval;
            data.addEvent();
        }
    }
    
    // Fit parameter
    Variable xalpha{"xalpha", -2, 0.1, -10, 10};
    // Fit parameter
    Variable yalpha{"yalpha", -2, 0.1, -10, 10};
    
    // GooPdf object
    ExpPdf xpdf{"xpdf", &xvar, &xalpha};
    ExpPdf ypdf{"ypdf", &yvar, &yalpha};
    ProdPdf totalpdf {"totalpdf", {&xpdf, &ypdf}};
    totalpdf.setData(&data);
    
    FitManager fitter{&totalpdf};
    fitter.fit();
    
    EXPECT_TRUE(fitter);
    EXPECT_LT(xalpha.error, .1);
    EXPECT_LT(yalpha.error, .1);
    EXPECT_NEAR(-1.5, xalpha.value, xalpha.error*3);
    EXPECT_NEAR(-.75, yalpha.value, yalpha.error*3);
}

TEST(BinnedFit, DifferentFitterVariable) {
    
    // Random number generation
    std::mt19937 gen(137);
    std::exponential_distribution<> dx(1.5);
    std::exponential_distribution<> dy(.75);
    
    // Independent variable.
    Variable xvar{"xvar", 0, 10};
    Variable yvar{"yvar", 0, 10};
    
    // Data set
    BinnedDataSet data {{&xvar, &yvar}, "Some name"};
    
    // Generate toy events.
    for(int i=0; i<200000; ++i) {
        double xval = dx(gen);
        double yval = dy(gen);
        if(xval < 10 && yval < 10) {
            xvar.value = xval;
            yvar.value = yval;
            data.addEvent();
        }
    }
    
    // Fit parameter
    Variable xalpha{"xalpha", -2, 0.1, -10, 10};
    // Fit parameter
    Variable yalpha{"yalpha", -2, 0.1, -10, 10};
    
    // GooPdf object
    ExpPdf ypdf{"ypdf", &yvar, &yalpha};
    ExpPdf xpdf{"xpdf", &xvar, &xalpha};
    ProdPdf totalpdf {"totalpdf", {&xpdf, &ypdf}};
    totalpdf.setData(&data);
    
    FitManager fitter{&totalpdf};
    fitter.fit();
    
    EXPECT_TRUE(fitter);
    EXPECT_LT(xalpha.error, .1);
    EXPECT_LT(yalpha.error, .1);
    EXPECT_NEAR(-1.5, xalpha.value, xalpha.error*3);
    EXPECT_NEAR(-.75, yalpha.value, yalpha.error*3);
}

