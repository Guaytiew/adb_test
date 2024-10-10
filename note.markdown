
# convert file ipynb to py 
jupyter nbconvert --to script your_notebook.ipynb


cmd to run test: pytest --cov=example
jenkins workspace path: C:\ProgramData\Jenkins\.jenkins\workspace\<job_name>\

STEP TO CICD:-
4. **Create a Jenkins Job**:
   - After setup, you can create your first job by clicking **"New Item"** on the Jenkins dashboard.
   - Choose either a **Freestyle project** (simple job configuration) or a **Pipeline project** (more complex, script-based CI/CD pipelines).

5. **Integrate Jenkins with Git**:
   - In your job configuration, go to the **Source Code Management** section and choose **Git**.
   - Enter your repository URL and credentials (if required) to enable Jenkins to pull code from your Git repository.

6. **Define Build Steps**:
   - In the **Build** section, specify the steps Jenkins should execute.
   - For example, you can set it up to run **unit tests** with PyTest, package applications, or deploy the code to a server.

7. **Automate Builds**:
   - Set up **triggers** (e.g., poll Git for new changes or use a webhook) to automate your builds.
   - This ensures that Jenkins runs the jobs whenever there’s new code pushed to your repository.

8. **Monitor Jobs**:
   - Once jobs are executed, Jenkins provides **logs**, **build status**, and other feedback so you can monitor the process.

### **Cost of Jenkins**
- **Free**: Jenkins itself is **open-source** and free to use.
- **Hosting costs**: If you run Jenkins on your own infrastructure (e.g., your local machine, a server, or a cloud provider like AWS or Azure), you may incur costs for **hosting**, **storage**, and **compute resources**.
- **Plugins**: Jenkins has a vast ecosystem of plugins, and most of them are **free**. However, some external services that integrate with Jenkins (like paid cloud providers or premium plugins) may have additional costs.


<!-- ------------------------------------CICD_example---------------------------------------------- -->
Deploying code to a **staging environment** is a crucial step in the **CI/CD pipeline**. A **staging environment** is an intermediate environment that closely resembles the **production environment**. It is used to test new changes (e.g., bug fixes, new features) before deploying them to the actual production environment where real users interact with the system.

The purpose of deploying code to staging is to simulate the real-world scenario with production-like data and infrastructure but without affecting the actual production environment. After successfully validating that the changes work as expected in staging, they can be moved to production.

### Example of Deploying Code to a Staging Environment

Let's assume you're using **Jenkins** as the CI/CD tool and **Azure** as the cloud provider.

### **Step-by-Step Example: Jenkins CI/CD Pipeline with Staging Deployment**

1. **Jenkins Pipeline Configuration**:
   - Jenkins allows you to create a **pipeline** that defines the steps required to build, test, and deploy your application.
   - You can write the pipeline using the Jenkins **Declarative Pipeline Syntax** or **Groovy** scripting.

```groovy
pipeline {
    agent any
    stages {
        // Stage 1: Build the code
        stage('Build') {
            steps {
                // Example: Building a Node.js application
                sh 'npm install'
            }
        }

        // Stage 2: Run Unit Tests
        stage('Test') {
            steps {
                // Example: Running tests using PyTest
                sh 'pytest --cov=app'
            }
        }

        // Stage 3: Deploy to Staging Environment
        stage('Deploy to Staging') {
            steps {
                // Example: Deploy to Azure using Azure CLI or Terraform
                sh 'az webapp deployment source config-zip --resource-group myResourceGroup --name myStagingApp --src staging.zip'
            }
        }

        // Stage 4: Manual Approval for Production
        stage('Approval') {
            steps {
                input 'Do you want to deploy to production?'
            }
        }

        // Stage 5: Deploy to Production Environment
        stage('Deploy to Production') {
            steps {
                // Example: Deploy to Production Environment
                sh 'az webapp deployment source config-zip --resource-group myResourceGroup --name myProductionApp --src production.zip'
            }
        }
    }
}
```

### Explanation of the Example:

1. **Build Stage**: 
   - Jenkins pulls the latest code and installs dependencies (e.g., in a Node.js app, it runs `npm install`).
   
2. **Test Stage**: 
   - Jenkins runs automated unit tests using PyTest. If any test fails, the pipeline stops here.

3. **Deploy to Staging**: 
   - If all tests pass, Jenkins deploys the code to the **staging environment** using the **Azure CLI** to push the application to a **staging web app**.
   - The staging environment is a replica of production, but it is only used for final validation and testing. For example, it may use real or sanitized data to test business logic and performance.
   
4. **Approval**: 
   - A manual step is introduced where a team member (such as a QA engineer or manager) reviews the deployment in staging. If everything works as expected, they approve the deployment to production.

5. **Deploy to Production**: 
   - After approval, Jenkins proceeds to deploy the application to the **production environment**, where it is live and available to end users.

### Common Tools for Staging Environment Deployment:
- **Azure App Services**: Staging slots allow you to deploy different versions of the application to different slots and swap between staging and production without downtime.
- **Kubernetes**: You can deploy your application to a Kubernetes cluster in a **staging namespace**.
- **AWS Elastic Beanstalk** or **Amazon EC2**: You can deploy to a staging environment using a different deployment group or environment configuration.

---

This pipeline ensures that code is properly tested and validated in a **staging environment** before being promoted to **production**, allowing teams to catch issues before they affect end-users.

Let me know if you'd like more details on how to set up a specific tool for deployment!



<!-- -----------------------------------SSHauthen_Git_Jenkins----------------------------------------------- -->
# change account which jenkins use (affect the sshkey path that jenkins point to, default is Local System account=> C:\Windows\System32\config\systemprofile, but if you use your account it'll be=> C:\Users\<YourUsername>\.ssh)
To check what your **Windows user account** is and use it for Jenkins instead of the **Local System Account**, follow these steps:

### Step 1: **Find Your User Account**

#### Option 1: Using Command Prompt
1. Open **Command Prompt** by pressing **Windows + R**, typing `cmd`, and pressing **Enter**.
2. In the command prompt, type:
   ```bash
   whoami
   ```
   This will display your current user account in the format: `domain\username` or `computername\username`.

#### Option 2: Using Control Panel
1. Open the **Control Panel**.
2. Go to **User Accounts** > **User Accounts**.
3. Your username will be displayed here along with your account details.

### Step 2: **Change Jenkins to Run as Your User Account**

Once you know your user account, you can change the Jenkins service to run under that account:

1. Open **Services** by pressing **Windows + R**, typing `services.msc`, and hitting **Enter**.
2. Find the **Jenkins** service, right-click it, and select **Properties**.
3. Go to the **Log On** tab.
4. Select **This account**.
5. Enter your username (you may need to add `.\` before your username if it's a local account) and your password.
6. Click **Apply**, then **OK**.
7. Restart the Jenkins service by right-clicking it and selecting **Restart**.

Now, Jenkins should use your user's `.ssh` folder (typically `C:\Users\<YourUsername>\.ssh`) for SSH keys.

Let me know if you need further clarification!