using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
[assembly: Xunit.CollectionBehavior(DisableTestParallelization = true)]

namespace IntegrationTests
{
   
    public class DockerTestServices : IDisposable
    {
        public DockerTestServices()
        {
            RemoveContainers();
            RunContainers();
        }


        public void Dispose()
        {
            RemoveContainers();
        }

        private static void RunContainers()
        {
            System.Diagnostics.Process.Start("docker", "run -d --name sql-integration-test -p 5433:1433 -e SA_PASSWORD=Pass@word -e ACCEPT_EULA=Y microsoft/mssql-server-linux");
            System.Diagnostics.Process.Start("docker", "run -d --name rabbitmq-test -p 5672:5672 rabbitmq");
            System.Diagnostics.Process.Start("docker", "run -d --name redis-test -p 6379:6379 redis");
            System.Diagnostics.Process.Start("docker", "run -d --name mongo-test -p 27017:27017 mongo");
        }

        private static void RemoveContainers()
        {
            System.Diagnostics.Process.Start("docker", "rm sql-integration-test -f").WaitForExit();
            System.Diagnostics.Process.Start("docker", "rm rabbitmq-test -f").WaitForExit();
            System.Diagnostics.Process.Start("docker", "rm redis-test -f").WaitForExit();
            System.Diagnostics.Process.Start("docker", "rm mongo-test -f").WaitForExit();
        }
    }
}
