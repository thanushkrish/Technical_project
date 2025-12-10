1) Java version was a huge headache while matching the one in the pom.xml with the actual version installed
   -- Checked the right version and replcaed with the actual one.

2) When the job failed, after multiple runs the job didn't run because of the old cache files stored in maven
    -- Cleaned the repo and maven package (the step was added in the jenkinsfile afterwards ) 
