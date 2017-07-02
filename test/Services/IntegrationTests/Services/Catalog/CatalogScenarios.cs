namespace IntegrationTests.Services.Catalog
{
    using Microsoft.EntityFrameworkCore;
    using Microsoft.eShopOnContainers.Services.Marketing.API.Infrastructure;
    using Polly;
    using System;
    using System.Data.SqlClient;
    using System.IO;
    using System.Threading.Tasks;
    using Xunit;

    public class CatalogScenarios : CatalogScenarioBase
    {
        [Fact]
        public async Task Get_get_all_catalogitems_and_response_ok_status_code()
        {
            using (var docker = new DockerTestServices())
            {
                using (var server = CreateServer())
                {
                    var response = await server.CreateClient()
                        .GetAsync(Get.Items);

                    response.EnsureSuccessStatusCode();
                }
            }
        }

        [Fact]
        public async Task Get_get_paginated_catalog_items_and_response_ok_status_code()
        {
            using (var docker = new DockerTestServices())
            {
                using (var server = CreateServer())
                {
                    var response = await server.CreateClient()
                        .GetAsync(Get.Paginated(0, 4));

                    response.EnsureSuccessStatusCode();
                }
            }
        }

        [Fact]
        public async Task Get_get_filtered_catalog_items_and_response_ok_status_code()
        {
            using (var docker = new DockerTestServices())
            {
                using (var server = CreateServer())
                {
                    var response = await server.CreateClient()
                        .GetAsync(Get.Filtered(1, 1));

                    response.EnsureSuccessStatusCode();
                }
            }
        }

        [Fact]
        public async Task Get_catalog_types_response_ok_status_code()
        {
            using (var docker = new DockerTestServices())
            {
                using (var server = CreateServer())
                {
                    var response = await server.CreateClient()
                        .GetAsync(Get.Types);

                    response.EnsureSuccessStatusCode();
                }
            }
        }

        [Fact]
        public async Task Get_catalog_brands_response_ok_status_code()
        {
            using (var docker = new DockerTestServices())
            {

                //var policy =  Policy.Handle<SqlException>().WaitAndRetryAsync(
                //    retryCount: 100,
                //    sleepDurationProvider: retry => TimeSpan.FromSeconds(Math.Pow(2, retry)),
                //    onRetry: (exception, timeSpan, retry, ctx) =>
                //    {
                //        Console.WriteLine($"Exception {exception.GetType().Name} with message ${exception.Message} detected on attempt {retry}");
                //    }
                //    );

                //await policy.ExecuteAsync(async () =>
                //{
                //    using (var conn = new SqlConnection("Server=tcp:127.0.0.1,5433;User Id=sa;Password=Pass@word"))
                //    {
                //        conn.Open();
                //    }
                //});

                using (var server = CreateServer())
                {
                    var response = await server.CreateClient()
                        .GetAsync(Get.Brands);

                    response.EnsureSuccessStatusCode();
                }
            }
        }
    }
}
