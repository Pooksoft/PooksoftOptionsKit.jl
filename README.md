![CI](https://github.com/Pooksoft/PooksoftOptionsKit.jl/workflows/CI/badge.svg)

### Introduction
``PooksoftOptionsKit.jl`` is a [Julia](https://www.julialang.org) package which computes the time value, profit/loss and probability of success for an arbitrary collection of [American or European](https://en.wikipedia.org/wiki/Option_style#American_and_European_options) options contracts. 
``PooksoftOptionsKit.jl`` is a member of the [Project Serenity](http://www.pooksoft.com) collection of packages from [Pooksoft](http://www.pooksoft.com), along with [PooksoftAssetModelingKit.jl](https://github.com/Pooksoft/PooksoftAssetModelingKit.jl) and 
[PooksoftAlphaVantageDataStore.jl](https://github.com/Pooksoft/PooksoftAlphaVantageDataStore.jl) packages. 

### Installation and Requirements
``PooksoftOptionsKit.jl`` requires Julia 1.5.x and above.
``PooksoftOptionsKit.jl`` is organized as a [Julia](http://julialang.org) package which 
can be installed in the ``package mode`` of Julia. 

To install ``PooksoftOptionsKit.jl`` in your project named ``my_project``, 
start the [Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/index.html) in the root directory of 
``my_project`` and enter the ``package mode`` using the ``]`` key (to get back press the ``backspace`` or ``^C`` keys).
``Package mode`` is the build in package management system in [Julia](http://julialang.org).
``Package mode`` documentation can be found [here](https://docs.julialang.org/en/v1/stdlib/Pkg/).
Once in package mode prompt enter the commands:

    (v1.5) pkg> activate .
    (v1.5) pkg> add https://github.com/pooksoft/PooksoftOptionsKit.jl.git

This will [activate](https://julialang.github.io/Pkg.jl/v1/api/#Pkg.activate) the current project, 
and install the ``PooksoftOptionsKit.jl`` package into the context of ``my_project``. 
To install other required packages, simply add them using the ``add`` command.
    

``CFMG.jl`` is open source, available under a [MIT software license](https://github.com/varnerlab/JuCFMG/blob/master/LICENSE).
You can download this repository as a zip file, clone or pull it by using the command (from the command-line):

	$ git pull https://github.com/varnerlab/CFMG.git

or

	$ git clone https://github.com/varnerlab/CFMG.git
