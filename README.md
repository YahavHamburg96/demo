
# Demo Application

This project involves creating an application that generates dummy data and stores it in a PostgreSQL database. The data generation is triggered by Apache Airflow. The application is designed to be deployed in a cloud environment with the following infrastructure components:

- **Application**:
  - A Flask-based Python application that generates and stores dummy data in PostgreSQL.
  - Triggered by an Airflow DAG to automate data generation.

- **Infrastructure**:
  - **VPC**: A Virtual Private Cloud to isolate resources.
  - **Subnets**: Public and private subnets for resource allocation.
  - **EKS**: Amazon Elastic Kubernetes Service for container orchestration.
  - **ECR**: Amazon Elastic Container Registry for storing Docker images.
  - **PostgreSQL RDS**: Amazon Relational Database Service for database management.
  - **Application Exposure**: Exposing the application to external users via a load balancer or ingress.

This README provides instructions for setting up the application, deploying the infrastructure, and understanding the functionality of the components.

## Application

This is a Python Flask application that interacts with a PostgreSQL database to generate and store random data.

### Key Features

- **Database Management**:
  - Ensures the specified PostgreSQL database and table (`dummy_data`) exist.
  - Automatically creates them if missing.

- **Data Generation**:
  - Generates random data using the Faker library.
  - Inserts the generated data into the PostgreSQL database.

- **Endpoints**:
  - `/health`: Health check endpoint returning `{'status': 'ok'}`.
  - `/generate-data`: Generates random data and inserts it into the database. Accepts a `count` query parameter to specify the number of records.


### Infrastructure

### `/terragrunt`
Contains configurations for managing infrastructure components using Terragrunt. It includes subfolders for different modules and environments.

### `_envcommon`
Shared configurations reused across multiple environments:
- **`infra`**: Shared configurations for infrastructure components like RDS, EKS, and ECR.
- **`app`**: Shared configurations for applications like Airflow and the dummy app.

### `demo`
Environment-specific configurations for the `demo` environment:
- **`network`**: Manages networking resources (VPC, subnets, etc.).
- **`infra`**: Manages infrastructure resources (RDS, EKS, ECR, etc.).
- **`app`**: Manages application deployments (Airflow, Nginx, dummy app).

### `/terragrunt/demo/network`
Networking configurations for the demo environment:
- **`vpc`**: Configuration for creating a Virtual Private Cloud (VPC).
- **`subnets`**: Configuration for creating public and private subnets within the VPC.

### `/terragrunt/demo/infra`
Infrastructure configurations for the demo environment:
- **`rds`**: Configuration for deploying a PostgreSQL database using Amazon RDS.
- **`eks`**: Configuration for deploying an Amazon EKS cluster for container orchestration.
- **`ecr`**: Configuration for deploying an Amazon ECR repository for storing Docker images.

### `/terragrunt/demo/app`
Application-specific configurations for the demo environment:
- **`airflow`**: Configuration for deploying Airflow, including DAGs and integration with other resources like RDS and EKS.
- **`dummy-app`**: Configuration for deploying the dummy app, which generates data and interacts with PostgreSQL.
- **`nginx`**: Configuration for deploying Nginx as a reverse proxy or load balancer.

### Purpose

The folder structure is designed to:
1. **Modularize Infrastructure**: Separate configurations for networking, compute, storage, and applications.
2. **Enable Reusability**: Share common configurations across environments using `_envcommon`.
3. **Support Environment-Specific Deployments**: Customize configurations for the `demo` environment.
4. **Automate Application Deployment**: Deploy applications like Airflow, Nginx, and the dummy app on top of the infrastructure.
5. **Integrate with Cloud Resources**: Use AWS services like VPC, RDS, EKS, and ECR for scalable and secure deployments.
