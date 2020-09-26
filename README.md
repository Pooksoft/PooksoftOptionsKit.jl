![CI](https://github.com/Pooksoft/PooksoftOptionsKit.jl/workflows/CI/badge.svg)

## Introduction
``PooksoftOptionsKit.jl`` is a package which computes the time value, profit/loss and probability of success for an arbitrary collection of [American or European options contracts](https://en.wikipedia.org/wiki/Option_style#American_and_European_options) using the [Julia programming language](https://www.julialang.org).
``PooksoftOptionsKit.jl`` is a member of the [Project Serenity](http://www.pooksoft.com) collection of packages from [Pooksoft](http://www.pooksoft.com), along with [PooksoftAssetModelingKit.jl](https://github.com/Pooksoft/PooksoftAssetModelingKit.jl) and 
[PooksoftAlphaVantageDataStore.jl](https://github.com/Pooksoft/PooksoftAlphaVantageDataStore.jl) packages. 

## Installation and Requirements
``PooksoftOptionsKit.jl`` requires [Julia 1.5.x](https://julialang.org/downloads/) or above.
``PooksoftOptionsKit.jl`` is organized as a [Julia](http://julialang.org) package which 
can be installed in the ``package mode`` of Julia. 

To install ``PooksoftOptionsKit.jl`` in your project ``my_project``, 
start the [Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/index.html) in the root directory of 
``my_project`` and enter the ``package mode`` using the ``]`` key (to get back press the ``backspace`` or ``^C`` keys).
``Package mode`` is the build in package management system in [Julia](http://julialang.org).
``Package mode`` documentation can be found [here](https://docs.julialang.org/en/v1/stdlib/Pkg/).
Once in package mode prompt enter the commands:

    (v1.5) pkg> activate .
    (v1.5) pkg> add https://github.com/Pooksoft/PooksoftOptionsKit.jl.git

This will [activate](https://julialang.github.io/Pkg.jl/v1/api/#Pkg.activate) ``my_project``, 
and install the ``PooksoftOptionsKit.jl`` package into the context of ``my_project``. 
To install other required packages, simply add them using the ``add`` command.

## Documentation
The documentation for the ``PooksoftOptionsKit.jl`` package can be found [here](https://pooksoft.github.io/PooksoftOptionsKit.jl/build/index.html).

## How do you get the code?
``PooksoftOptionsKit.jl`` is an open source project, 
available under a [MIT software license](https://github.com/Pooksoft/PooksoftOptionsKit.jl/blob/master/LICENSE).
You can download this repository as a [zip file](https://en.wikipedia.org/wiki/Zip_(file_format)), clone or pull it by using the command (from the command-line):

	$ git pull https://github.com/Pooksoft/PooksoftOptionsKit.jl.git

or

	$ git clone https://github.com/Pooksoft/PooksoftOptionsKit.jl.git

and pretty much do anything you want with it. However, if you do pull the code, drop us a 
[star](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/saving-repositories-with-stars) to keep track of the latest and greatest updates.

## How do I contribute to this package, or other Serenity packages?
[Fork the project](https://guides.github.com/activities/forking/) and go crazy with it!
Check out [Rob Allen's DevNotes](https://akrabat.com/the-beginners-guide-to-contributing-to-a-github-project/)
for a beginner's guide to contributing to a GitHub project to get started. 


