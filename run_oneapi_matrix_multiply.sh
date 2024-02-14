#!/bin/bash

# Compile the SYCL code
/bin/echo "##" $(whoami) is compiling xpublog 1 -- Matrix Multiply - oneapi_matrix_multiply.cpp
make

# Run the compiled code
/bin/echo "##" $(whoami) is running xpublog 1 -- Matrix Multiply - oneapi_matrix_multiply.cpp
make run

# Display a message indicating that the job has been submitted
echo "Job has been submitted to Intel(R) DevCloud and will execute soon."
echo ""
echo " If you do not see the result in 60 seconds, please restart the Jupyter kernel:"
echo " Kernel -> 'Restart Kernel and Clear All Outputs...' and then try again"

# Submit the job using qsub
qsub_id=$(qsub run_oneapi_matrix_multiply.sh)
job_id="$(cut -d'.' -f1 <<<"$qsub_id")"

# Display qstat output
qstat

# Wait for the output file to be generated and display progress
echo ""
echo -ne "Waiting for Output "
timeout=0
until [ -f run_oneapi_matrix_multiply.sh.o$job_id ]; do
    sleep 1
    echo -ne "█"
    ((timeout++))
    # Timeout if no output file is generated within 60 seconds
    if [ $timeout == 60 ]; then
        echo ""
        echo ""
        echo "TimeOut 60 seconds: Job is still queued for execution, check for output file later (run_oneapi_matrix_multiply.sh.o$job_id)"
        echo ""
        break
    fi
done

# Print output and error file content if they exist
if [ -n "$(find -name '*.sh.o'$job_id)" ]; then
    echo " Done⬇"
    cat run_oneapi_matrix_multiply.sh.o$job_id
    cat run_oneapi_matrix_multiply.sh.e$job_id
    echo "Job Completed in $timeout seconds."
    rm *.sh.*$job_id > /dev/null 2>&1
fi
