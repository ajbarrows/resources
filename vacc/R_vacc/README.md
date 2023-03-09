# Running R Processes on the Vermont Advanced Computing Core (VACC)

## Overview

R users are typically accustomed to running scripts interactively (i.e., opening RStudio, creating a script or R Markdown document, and running it bit by bit). When using the VACC (or other compute clusters), it's important to drop this mindset. 

R has a built-in function [`Rscript`](https://www.rdocumentation.org/packages/utils/versions/3.6.2/topics/Rscript), which allows the user to call a `.R` file from a Unix terminal or Bash script. 
<!---
### Environments

The first step toward running R scripts on the VACC is to install R in a way that's accessible through your user account. Unfortunately, R lacks robust support for the kinds of virtual environments that Python users are accustomed to seeing. However, Anaconda, the data science platform popular with Python users, offers [limited support](https://docs.anaconda.com/anaconda/user-guide/tasks/using-r-language/) for the R language. 

A key limitation is that packages come through Anaconda's `conda-forge` channel, rather than through [CRAN](https://cran.r-project.org/). In principle, this could mean that CRAN has a newer version than `conda-forge` of an R library you're looking to use. In practice, I find this rarely matters, and the more important thing is ensuring you use the _same_ version for all aspects of your project. Or, at the very least, you know _which_ version you used if ever you need to chase down a bug.
--->

### Package Management
The first step toward running R scripts on the VACC is to install R in a way that's accessible through your user account. One way to do this is to use an environment.

#### Environments
Unfortunately, R lacks robust support for the kinds of virtual environments that Python users are accustomed to seeing. However, Anaconda, the data science platform popular with Python users, offers [limited support](https://docs.anaconda.com/anaconda/user-guide/tasks/using-r-language/) for the R language. 

A key limitation is that packages come through Anaconda's `conda-forge` channel, rather than through [CRAN](https://cran.r-project.org/). In principle, this could mean that CRAN has a newer version than `conda-forge` of an R library you're looking to use. In practice, I find this rarely matters, and the more important thing is ensuring you use the _same_ version for all aspects of your project. Or, at the very least, you know _which_ version you used if ever you need to chase down a bug.

#### Package Management
Another (more tedious, but potentially more straightforward) is to use one of the package managers that the VACC already has installed. If Anaconda environments aren't working out, you can use Spack. Instructions are specified on [this page. ](https://www.uvm.edu/vacc/kb/knowledge-base/load-software-packages/#modules).

### Batch Computing

A key difference between using your workstation to run R processes and using a compute cluster like the VACC is batch computing. The end-user rarely has to think about the complexities involved with managing a high-performance compute cluster because of handy tools used to submit jobs into a _batch system_. Instead of running your process locally, this batch system runs it for you, according to parameters you've specified. You may monitor the job's progress (to an extent), and ultimately retrieve its output upon completion (or failure). Because of this, it's critical that your code sends all relevant output (e.g., processed data, statistical results, visualizations) to a pre-defined filepath, because you cannot retrieve "outputs" from an interactive session like you can in RStudio.

[Slurm](https://en.wikipedia.org/wiki/Slurm_Workload_Manager) is the batch system manager used at the VACC. The VACC offers an [overview](https://www.uvm.edu/vacc/kb/knowledge-base/understand-batch-system/) of what job submission entails, but I'll try to provide a working example here.

## Get Started

### Connect to a Cluster

We're going to use the compute cluster _Bluemoon_ for this example, and you'll likely use it for most things, too. Details on Bluemoon and other clusters are available [here](https://www.uvm.edu/vacc/cluster-specs).

First, establish a connection to Bluemoon through SSH. I strongly recommend setting up key-based authentication. On macOS, open a Terminal window and enter:

		$ ssh-keygen
		
Follow the prompts to generate a new _public key_ called `id_rsa.pub`. Then, copy your new public key to Bluemooon:

		$ ssh-copy-id netID@vacc-user1.uvm.edu

You'll likely see a message saying that the "authenticity" of the host cannot be established. This is safe, and you should type `yes` to continue connecting. The terminal will then prompt you for your UVM netID password. If your public key is installed successfully, the terminal will give instructions to connect:

		$ ssh netID@vacc-user1.uvm.edu
		
This connection should proceed without requiring you to enter your netID password.



### Gather Necessary packages

While connected to Bluemoon, use

		[ajbarrow@vacc-user1 ~]$ spack find

to search for available packages. The easiest way to load packages is to add them to the shell script you'll use to submit the job. For the current example, I've added:

		spack load r@3.6.3
		spack load r-dplyr@0.8.3
		spack load r-tidyr@0.8.3
		
		

### Configure a Project for Batch Submission

The directory where this `README.md` file is saved is (arguably) an example of an appropriate file structure for a data science project. Copy this directory to Bluemoon by opening a Terminal window from this directory. The easiest way to do this on macOS is by right-clicking the *parent* (that is, `R_vacc/`) directory and selecting 'New Terminal at Folder'. In the terminal window that opens, verify you're in the right place:

		$ tony@tonyMacBookPro R_vacc

Now, use the Unix command `rsync` to copy this directory to Bluemoon. The basic structure of an `rsync` command is:

		$ rsync -flag local remote

where `local` is the file or directory you wish to copy, and `remote` is the target location. The `-flag` argument allows you to use different aspects of `rsync`'s functionality. For example, the `-a` flag stands for "archive" mode, which copies directories recursively and preserves symbolic links. This will become important. The `v` flag stands for "verbose," which forces `rsync` to print success and failure in the terminal, and the `-P` flag stands for "progress," which is helpful when transferring large files.

So, to copy this project's directory to Bluemoon:

		$ rsync -avP ./ netID@vacc-user1.uvm.edu:scratch/

Notice the `./` which refers to the current directory. Also notice the `:`, which allows you to specify the remote directory. 

### Run the Job

I have included a sample Bash script designed to submit your job to Slurm. There are many, many configuration options. The most important ones:

		#SBATCH --partition=short			# use Bluemoon for lengthy jobs
		#SBATCH --nodes=1					# number of compute nodes -- usually no need to change
		#SBATCH --ntasks=2					# number of processor cores -- important for parallelized code
		#SBATCH --time=3:00					# expected job time: estimate this correctly. If too short, your job won't complete.
		#SBATCH --mem=2G						# amount of RAM
		#SBATCH --job-name=R_vacc_test	# job name for monitoring
		#SBATCH --output=%x_%j.out			# output file
		#SBATCH --mail-type=ALL				# prompts Slurm to send you emails when the job starts, completes, or fails

These parameters will work for a very short task, like the one in this guide. You'll want to consult the [VACC's documentation](https://www.uvm.edu/vacc/kb/knowledge-base/write-submit-job-bluemoon/) for configuring larger jobs. 

In the Terminal connected to Bluemoon by SSH, navigate to the directory you just placed:

		[ajbarrow@vacc-user1 ~]$ cd ~/scratch/R_vacc
		
Now, submit the job using the `sbatch` command:

		[ajbarrow@vacc-user1 ~]$ sbatch R_vacc_test.sh
		
You should see a response in the form of:

		# where "1234" would be replaced with YOUR Slurm job ID
		Submitted batch job 1234
		
Your job is now in the queue. The queue is typically short, and your job will likely be executed immediately. You should receive an email detailing this. If this were a job that was expected to run for a long time, you could and manage the job using [these instructions.](https://www.uvm.edu/vacc/kb/knowledge-base/monitor-and-manage-a-job/)

### Retrieve the Output

Now that the job is complete, you want to retrieve the output. Navigate to the `R_vacc` project directory _on your workstation_, and enter the reverse of the `rsync` command we used earlier:

		$ rsync -avP netID@vacc-user1.uvm.edu:scratch/R_vacc/ ./


------


### Install a Conda Environment

If you want to try using Anaconda environments...

Follow the steps on [this page ](https://www.uvm.edu/vacc/kb/knowledge-base/install-anaconda-or-miniconda/) to install Anaconda on your VACC user account.

When you create an environment, you should attempt to include the core packages you will require. You must also include `r-base` and `r-essentials`, which is the collection of packages that make up R's core functionalities. You may also want the popular `tidyverse` package, which installs component packages like `dplyr`, `tidyr`, and `ggplot2`. For example, to create an environment called `MyNewEnvironment`:

		$ conda create -n MyNewEnvironment r-essentials r-base r-tidyverse
		
Now there's an installation of R and the core packages you'll need for your project. **You should make a new environemnt for each project.**

If you encounter errors like `Solving environment` taking forever, 

In order to access the R installation and libraries:

		$ conda activate MyNewEnvironment




<!--- package `parglm` for parallel -->

	