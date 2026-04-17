⭐ **[2026-1 Mid-term Project - INDEX](../2026-1_Mid-term_Project.md)**

---
title: "Computational Fluid Dynamics Volume I"
authors:
  - "Klaus A. Hoffmann"
  - "Steve T. Chiang"
year: "2000"
abstract: ""
---

Fourth Edition

# COMPUTATIONAL FLUID DYNAMICS
# VOLUME I

KLAUS A. HOFFMANN
STEVE T. CHIANG

ODTÜ KÜTÜPHANESİ
M. E. T. C. LIBRARY

A Publication of Engineering Education System™, Wichita, Kansas, 67208-1078, USA

www.EESbooks.com

Copyright ©2000, 1998, 1993, 1989 by Engineering Education System. All rights reserved. No part of this publication may be reproduced or distributed in any form or by any means, mechanical or electronic, including photocopying, recording, storage or retrieval system, without prior written permission from the publisher.

The data and information published in this book are for information purposes only. The authors and publisher have used their best effort in preparing this book. The authors and publisher are not liable for any injury or damage due to use, reliance, or performance of materials appearing in this book.

ISBN 0-9623731-0-9
First Print: August 2000

This book is typeset by Jeanie Duvall dba SciTech Computer Typesetting of Austin, Texas.

To obtain information on purchasing this or other texts published by EES, please write to:
Engineering Education System™
P.O. Box 20078
Wichita, KS 67208-1078
USA
Or visit:
www.EESbooks.com

# CONTENTS

Preface 1
Introduction 1

## Chapter One:
## Classification of Partial Differential Equations 3

*   1.1 Introductory Remarks 3
*   1.2 Linear and Nonlinear Partial Differential Equations 3
*   1.3 Second-Order Partial Differential Equations 4
*   1.4 Elliptic Equations 6
*   1.5 Parabolic Equations 6
*   1.6 Hyperbolic Equations 8
*   1.7 Model Equations 10
*   1.8 System of First-Order Partial Differential Equations 11
*   1.9 System of Second-Order Partial Differential Equations 16
*   1.10 Initial and Boundary Conditions 20
*   1.11 Remarks and Definitions 22
*   1.12 Summary Objectives 24
*   1.13 Problems 25

## Chapter Two:
## Finite Difference Formulations 29

*   2.1 Introductory Remarks 29
*   2.2 Taylor Series Expansion 29
*   2.3 Finite Difference by Polynomials 35
*   2.4 Finite Difference Equations 37

ii
Contents

*   2.5 Applications 40
*   2.6 Finite Difference Approximation of Mixed Partial Derivatives 51
    *   2.6.1 Taylor Series Expansion 51
    *   2.6.2 The Use of Partial Derivatives with Respect to One Independent Variable 52
*   2.7 Summary Objectives 53
*   2.8 Problems 55

## Chapter Three:
## Parabolic Partial Differential Equations 60

*   3.1 Introductory Remarks 60
*   3.2 Finite Difference Formulations 60
*   3.3 Explicit Methods 64
    *   3.3.1 The Forward Time/Central Space Method 64
    *   3.3.2 The Richardson Method 64
    *   3.3.3 The DuFort-Frankel Method 64
*   3.4 Implicit Methods 65
    *   3.4.1 The Laasonen Method 66
    *   3.4.2 The Crank-Nicolson Method 66
    *   3.4.3 The Beta Formulation 67
*   3.5 Applications 67
*   3.6 Analysis 72
*   3.7 Parabolic Equations in Two-Space Dimensions 76
*   3.8 Approximate Factorization 85
*   3.9 Fractional Step Methods 87
*   3.10 Extension to Three-Space Dimensions 87
*   3.11 Consistency Analysis of Finite Difference Equations 88
*   3.12 Linearization 90
*   3.13 Irregular Boundaries 92
*   3.14 Summary Objectives 94
*   3.15 Problems 96

iii
Contents

## Chapter Four:
## Stability Analysis 113

*   4.1 Introductory Remarks 113
*   4.2 Discrete Perturbation Stability Analysis 114
*   4.3 Von Neumann Stability Analysis 124
*   4.4 Multidimensional Problems 137
*   4.5 Error Analysis 141
*   4.6 Modified Equation 143
*   4.7 Artificial Viscosity 146
*   4.8 Summary Objectives 148
*   4.9 Problems 149

## Chapter Five:
## Elliptic Equations 152

*   5.1 Introductory Remarks 152
*   5.2 Finite Difference Formulations 152
*   5.3 Solution Algorithms 156
    *   5.3.1 The Jacobi Iteration Method 157
    *   5.3.2 The Point Gauss-Seidel Iteration Method 160
    *   5.3.3 The Line Gauss-Seidel Iteration Method 162
    *   5.3.4 Point Successive Over-Relaxation Method (PSOR) 164
    *   5.3.5 Line Successive Over-Relaxation Method (LSOR) 165
    *   5.3.6 The Alternating Direction Implicit Method (ADI) 165
*   5.4 Applications 167
*   5.5 Summary Objectives 174
*   5.6 Problems 175

iv
Contents

## Chapter Six:
## Hyperbolic Equations 185

*   6.1 Introductory Remarks 185
*   6.2 Finite Difference Formulations 185
    *   6.2.1 Explicit Formulations 186
        *   6.2.1.1 Euler's FTFS Method 186
        *   6.2.1.2 Euler's FTCS Method 186
        *   6.2.1.3 The First Upwind Differencing Method 186
        *   6.2.1.4 The Lax Method 186
        *   6.2.1.5 Midpoint Leapfrog Method 186
        *   6.2.1.6 The Lax-Wendroff Method 187
    *   6.2.2 Implicit Formulations 188
        *   6.2.2.1 Euler's BTCS Method 188
        *   6.2.2.2 Implicit First Upwind Differencing Method 188
        *   6.2.2.3 Crank-Nicolson Method 188
*   6.3 Splitting Methods 189
*   6.4 Multi-Step Methods 189
    *   6.4.1 Richtmyer/Lax-Wendroff Multi-Step Method 189
    *   6.4.2 The MacCormack Method 190
*   6.5 Applications to a Linear Problem 191
*   6.6 Nonlinear Problem 206
    *   6.6.1 The Lax Method 207
    *   6.6.2 The Lax-Wendroff Method 208
    *   6.6.3 The MacCormack Method 211
    *   6.6.4 The Beam and Warming Implicit Method 213
    *   6.6.5 Explicit First-Order Upwind Scheme 218
    *   6.6.6 Implicit First-Order Upwind Scheme 218
    *   6.6.7 Runge-Kutta Method 219
    *   6.6.8 Modified Runge-Kutta Method 225
*   6.7 Linear Damping 228
    *   6.7.1 Application 231

v
Contents

*   6.8 Flux Corrected Transport 233
    *   6.8.1 Application 235
*   6.9 Classification of Numerical Schemes 236
    *   6.9.1 Monotone Schemes 236
    *   6.9.2 Total Variation Diminishing Schemes 237
    *   6.9.3 Essentially Non-Oscillatory Schemes 238
*   6.10 TVD Formulations 238
    *   6.10.1 First-Order TVD Schemes 239
    *   6.10.2 Entropy Condition 243
    *   6.10.3 Application 243
    *   6.10.4 Second-Order TVD Schemes 244
        *   6.10.4.1 Harten-Yee Upwind TVD Limiters 245
        *   6.10.4.2 Roe-Sweby Upwind TVD Limiters 247
        *   6.10.4.3 Davis-Yee Symmetric TVD Limiters 250
*   6.11 Modified Runge-Kutta Method with TVD 251
*   6.12 Summary Objectives 253
*   6.13 Problems 254

## Chapter Seven:
## Scalar Representation of the Navier-Stokes Equations 272

*   7.1 Introductory Remarks 272
*   7.2 Model Equation 273
*   7.3 Equations of Fluid Motion 274
*   7.4 Numerical Algorithms 276
    *   7.4.1 FTCS Explicit 276
    *   7.4.2 FTBCS Explicit 277
    *   7.4.3 DuFort-Frankel Explicit 277
    *   7.4.4 MacCormack Explicit 278
    *   7.4.5 MacCormack Implicit 278
    *   7.4.6 BTCS Implicit 279

vi
Contents

    *   7.4.7 BTBCS Implicit 279
*   7.5 Applications: Nonlinear Problem 280
    *   7.5.1 FTCS Explicit 282
    *   7.5.2 FTBCS Explicit 285
    *   7.5.3 DuFort-Frankel Explicit 285
    *   7.5.4 MacCormack Explicit 286
    *   7.5.5 MacCormack Implicit 287
    *   7.5.6 BTCS Implicit 289
    *   7.5.7 BTBCS Implicit 289
    *   7.5.8 Modified Runge-Kutta 290
    *   7.5.9 Second-Order TVD Schemes 292
*   7.6 Summary Objectives 294
*   7.7 Problems 295

## Chapter Eight:
## Incompressible Navier-Stokes Equations 302

*   8.1 Introductory Remarks 302
*   8.2 Incompressible Navier-Stokes Equations 303
    *   8.2.1 Primitive Variable Formulations 304
    *   8.2.2 Vorticity-Stream Function Formulations 307
    *   8.2.3 Comments on Formulations 309
*   8.3 Poisson Equation for Pressure: Primitive Variables 310
*   8.4 Poisson Equation for Pressure: Vorticity-Stream Function Formulation 311
*   8.5 Numerical Algorithms: Primitive Variables 314
    *   8.5.1 Steady Flows 315
        *   8.5.1.1 Artificial Compressibility 315
        *   8.5.1.2 Solution on a Regular Grid 316
        *   8.5.1.3 Crank-Nicolson Implicit 321
*   8.6 Boundary Conditions 322
    *   8.6.1 Body Surface 323
    *   8.6.2 Far-Field 325
    *   8.6.3 Symmetry 325

vii
Contents

    *   8.6.4 Inflow 326
    *   8.6.5 Outflow 326
    *   8.6.6 An Example 326
*   8.7 Staggered Grid 328
    *   8.7.1 Marker and Cell Method 330
    *   8.7.2 Implementation of the Boundary Conditions 332
    *   8.7.3 DuFort-Frankel Scheme 333
    *   8.7.4 Use of the Poisson Equation for Pressure 334
    *   8.7.5 Unsteady Incompressible Navier-Stokes Equations 335
*   8.8 Numerical Algorithms: Vorticity-Stream Function Formulation 337
    *   8.8.1 Vorticity Transport Equation 338
    *   8.8.2 Stream Function Equation 343
*   8.9 Boundary Conditions 343
    *   8.9.1 Body Surface 344
    *   8.9.2 Far-Field 346
    *   8.9.3 Symmetry 346
    *   8.9.4 Inflow 347
    *   8.9.5 Outflow 348
*   8.10 Application 348
*   8.11 Temperature Field 351
    *   8.11.1 The Energy Equation 352
    *   8.11.2 Numerical Schemes 354
    *   8.11.3 Boundary Conditions 355
*   8.12 Problems 357

## Chapter Nine:
## Grid Generation – Structured Grids 358

*   9.1 Introductory Remarks 358
*   9.2 Transformation of the Governing Partial Differential Equations 362
*   9.3 Metrics and the Jacobian of Transformation 363
*   9.4 Grid Generation Techniques 364
*   9.5 Algebraic Grid Generation Techniques 365

viii
Contents

*   9.6 Partial Differential Equation Techniques 383
*   9.7 Elliptic Grid Generators 383
    *   9.7.1 Simply-Connected Domain 385
    *   9.7.2 Doubly-Connected Domain 395
    *   9.7.3 Multiply-Connected Domain 401
*   9.8 Coordinate System Control 404
    *   9.8.1 Grid Point Clustering 404
    *   9.8.2 Orthogonality at the Surface 407
*   9.9 Hyperbolic Grid Generation Techniques 411
*   9.10 Parabolic Grid Generators 418
*   9.11 Problems 420

# Appendices

*   Appendix A: An Introduction to Theory of Characteristics: Wave Propagation 426
*   Appendix B: Tridiagonal System of Equations 438
*   Appendix C: Derivation of Partial Derivatives for the Modified Equations 443
*   Appendix D: Basic Equations of Fluid Mechanics 445
*   Appendix E: Block-Tridiagonal System of Equations 464
*   Appendix F: Derivatives in the Computational Domain 473

# References 478
# Index 481