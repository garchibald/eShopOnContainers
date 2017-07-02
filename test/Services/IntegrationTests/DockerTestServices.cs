using System;
using System.Collections.Generic;
using System.Text;

namespace IntegrationTests
{
    public class DockerTestServices : IDisposable
    {
        public DockerTestServices()
        {
            System.Diagnostics.Process.Start("docker", "run -d --name sql-integration-test -p 5433:1433 -e SA_PASSWORD=Pass@word -e ACCEPT_EULA=Y microsoft/mssql-server-linux");
            System.Diagnostics.Process.Start("docker", "run -d --name rabbitmq-test -p 5672:5672 rabbitmq");
            System.Diagnostics.Process.Start("docker", "run -d --name redis-test -p 6379:6379 redis");
            System.Diagnostics.Process.Start("docker", "run -d --name mongo-test -p 27017:27017 mongo");
        }

        public void Dispose()
        {
            System.Diagnostics.Process.Start("docker", "rm sql-integration -f");
            System.Diagnostics.Process.Start("docker", "rm rabbitmq-test -f");
            System.Diagnostics.Process.Start("docker", "rm redis-test -f");
            System.Diagnostics.Process.Start("docker", "rm mongo-test -f");
        }
    }
}
