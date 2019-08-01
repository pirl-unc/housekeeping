The purpose of this package is to add tools that are needed for basic debugging and package manipulation tasks.  


## Debugging  
To debug it's often helpful to pull in the variables of a function into the global environment and work with the lines of a function there without using the debugger. To do this manulally you need to copy the called arguments, delete the commas and then do the same for the default function variables. If you are trying to get 3+ nested functions in, this can be annoying.   

These two functions are designed to help with that:  
* function_var_to_env - puts all of the function variables in a specified environment (usually global) to make it as if you are working insdie of the function  
* function_to_function - runs from the beginning of fun_name_1 to the start of fun_name_2 and then runs function_var_to_env on that second function  

### function_var_to_env  
Takes the text used to call a function and calls all of the variables in that function into whatever environment you want, global for me.  If any variables weren't used in the call it uses the default function values and puts those in the environment so you can debug the function in the global environment. For example:  
  
``` r
fun_a = function(var_a = 10, var_b = "b"){
    print(paste0("var_a: ", var_a))
    print(paste0("var_b: ", var_b))
}  
```

At this point the variables aren't in the global env
``` r
var_a     # Error: object 'var_a' not found
var_b     # Error: object 'var_b' not found
```

Now assign the function text you want to dig into to a variable and run function_var_to_env  
fun_a_txt = 'fun_a(var_a=1.5)'
function_var_to_env(fun_a_txt)
   
These variables are now in the global environment.
``` r
var_a     # 1.5
var_b     # 'b'
```

### function_to_function  
If the example for function_var_to_env was run then we can run all the code up to fun_name_2 and function_to_function on fun_name_2 by using this function:  
``` r
fun_b = function(var_a=1){
  print("start fun_b ----------")
  print(paste0("var_a: ", var_a))
  print(paste0("changed var_a: "))
  var_a = var_a + 1
  print(paste0("var_a: ", var_a))
  print("running fun_a ----------")
  fun_a(
    var_a = var_a
  )
}
```

Then run:  
``` r
function_var_to_env(called_fun = fun_b_txt)
function_to_function(fun_name_1 = "fun_b", fun_name_2 = "fun_a")
```


## Finding script locations  

### get_script_path  
It's often helpful for scripts to know where they are.  This way they can write files in their same folder even if that folder is moved.  This script is an attempt to do that.  It should work if the script containing get_script_path is sourced from: an Rscript, RStudio console, or RStudio source.  It should also work if run through RStudio.  If called from a function it will take the path from the script that called it.  Also if it is sourced form a source, it will take the path of the parent source.  For use in functions I use it like this:  

``` r
sample_script_path = get_script_path()
do_something = function(script_path = sample_script_path){
  print(script_path)
}
```

This way the path will be assigned to the function when the function is sourced.

I used this SO question as a starting point: [rscript-determine-path-of-the-executing-script](https://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script)



## Package Tools

### detach_package  
Detaches every instance of a package  


### remove_package_from_all_libraries  
nt  

### package_is_loaded  
Tells if a package is loaded  


### get_loaded_package_version  
nt  


### matches_loaded_version  
Tells if entered version matches that of the loaded version  


### get_package_version_listed_in_description  
nt  


### assemble_package  
Save lots of steps in making new packages  
* Modifies the version listed in the DESCRIPTION file  
* Deletes the tar file from any older packages
* Runs devtools::document on the package
* If should_build, builds the package to make tar.gz file
* Tries to load the package.  If it doesn't work, the DESCRIPTION file goes back to the original version

## Assembling this package
In R: 
``` r
housekeeping::assemble_package(package_name = "housekeeping", my_version = "0.1-10",
  my_dir = "/datastore/alldata/shiny-server/rstudio-common/dbortone/packages/housekeeping")
```

In bash:
``` bash
cd /datastore/alldata/shiny-server/rstudio-common/dbortone/packages/housekeeping
my_comment="assembled package."
git commit -am "$my_comment"; git push origin master
git tag -a 0.1-10 -m "$my_comment"; git push -u origin --tags
```

Restart R
In R (local library, packrat library):
``` r
devtools::install_bitbucket("BGV_DBortone/housekeeping")
packrat::snapshot(infer.dependencies = F)
```

In bash also add change to the rstudio library for running on slurm:
``` bash
# load image in interactive area
ssh dbortone@cv-shell.bioinf.unc.edu 

# if you need to get the image from Sai...
download link
gunzip r352-114-v4-seurat-umap_latest.tar.gz
chmod ugo+x r352-114-v4-seurat-umap_latest.tar # necessary?
srun --pty -c 1 --mem 1g -w r820-docker-2-0.local  -p docker bash
cat r352-114-v4-seurat-umap_latest.tar | docker image load

docker tag r352-114-v4-seurat-umap:latest dockerreg.bioinf.unc.edu:5000/r352-114-v4-seurat-umap:latest

# run it
docker run --name bob --rm -v /datastore:/datastore:shared -it dockerreg.bioinf.unc.edu:5000/r352-114-v4-seurat-umap:latest bash


# install 
Rscript -e 'devtools::install_github("rstudio/rstudioapi")'
Rscript -e 'devtools::install_bitbucket("BGV_DBortone/housekeeping")'

# save container as image from another terminal
docker container ls
docker commit bob dockerreg.bioinf.unc.edu:5000/r352-114-v4-seurat-umap:dsb1

# save it so we can access from a node
docker image save -o r352-114-v4-seurat-umap_dsb1 dockerreg.bioinf.unc.edu:5000/r352-114-v4-seurat-umap:dsb1
exit
# couldn't get the docker nodes to see the image no matter how I pushed or pulled
srun --pty -c 1 --mem 1g -w r820-docker-2-0.local  -p docker bash
cat r352-114-v4-seurat-umap_dsb1 | docker image load
docker push dockerreg.bioinf.unc.edu:5000/r352-114-v4-seurat-umap:dsb1
singularity pull docker://dockerreg.bioinf.unc.edu:5000/r352-114-v4-seurat-umap:dsb1

```


