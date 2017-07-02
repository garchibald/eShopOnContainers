using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.eShopOnContainers.Services.Catalog.API.Controllers;
using Microsoft.eShopOnContainers.WebMVC.ViewModels;
using Moq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Xunit;
using CatalogModel = Microsoft.eShopOnContainers.WebMVC.ViewModels.Catalog;

namespace UnitTest.Catalog.Application
{
    public class PicControllerTest
    {
        private readonly Mock<IHostingEnvironment> _hostingEnvironmentMock;
        private string _tempPath;

        public PicControllerTest()
        {
            _hostingEnvironmentMock = new Mock<IHostingEnvironment>();
            _tempPath = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString());
            Directory.CreateDirectory(_tempPath);
        }

        ~PicControllerTest()
        {
            ForceDeleteDirectory(_tempPath);
        }

        public static void ForceDeleteDirectory(string path)
        {
            var directory = new DirectoryInfo(path) { Attributes = FileAttributes.Normal };

            foreach (var info in directory.GetFileSystemInfos("*", SearchOption.AllDirectories))
            {
                info.Attributes = FileAttributes.Normal;
            }

            directory.Delete(true);
        }

        [Fact]
        public async Task Get_Pic_no_extension_success()
        {
            //Arrange
            _hostingEnvironmentMock.SetupGet(x => x.WebRootPath).Returns(_tempPath);
            File.WriteAllText(Path.Combine(_tempPath, "1.png"), "<IMAGE>");
            
            //Act
            var picController = new PicController(_hostingEnvironmentMock.Object, null);
            var actionResult = picController.GetImage("1");

            //Assert
            var fileResult = Assert.IsType<FileContentResult>(actionResult);
            Assert.Equal("1.png", fileResult.FileDownloadName);
        }

        [Theory]
        [InlineData("1.png", "image/png")]
        [InlineData("1.gif", "image/gif")]
        [InlineData("1.jpg", "image/jpeg")]
        [InlineData("1.jpeg", "image/jpeg")]
        [InlineData("1.bmp", "image/bmp")]
        [InlineData("1.tiff", "image/tiff")]
        [InlineData("1.wmf", "image/wmf")]
        [InlineData("1.jp2", "image/jp2")]
        [InlineData("1.svg", "image/svg+xml")]
        [InlineData("1.other", "application/octet-stream")]
        public async Task Get_Pic_mime(string input, string expectedMimeType)
        {
            //Arrange
            _hostingEnvironmentMock.SetupGet(x => x.WebRootPath).Returns(_tempPath);
            File.WriteAllText(Path.Combine(_tempPath, input), "<IMAGE>");

            //Act
            var picController = new PicController(_hostingEnvironmentMock.Object, null);
            var actionResult = picController.GetImage(input);

            //Assert
            var fileResult = Assert.IsType<FileContentResult>(actionResult);
            Assert.Equal(expectedMimeType, fileResult.ContentType);
        }


        [Fact]
        public async Task Not_found_result_if_invalid_file()
        {
            //Arrange
            _hostingEnvironmentMock.SetupGet(x => x.WebRootPath).Returns(_tempPath);

            //Act
            var picController = new PicController(_hostingEnvironmentMock.Object, null);
            var actionResult = picController.GetImage("1");

            //Assert
            Assert.IsType<NotFoundResult>(actionResult);
        }

        [Fact]
        public async Task Not_found_result_if_no_local_file()
        {
            //Arrange
            _hostingEnvironmentMock.SetupGet(x => x.WebRootPath).Returns(_tempPath);
            Directory.CreateDirectory(Path.Combine(_tempPath, "Foo"));
            File.WriteAllText(Path.Combine(_tempPath, "Foo", "1.png"), "<IMAGE>");

            //Act
            var picController = new PicController(_hostingEnvironmentMock.Object, null);
            var actionResult = picController.GetImage(@"Foo\1.png");

            //Assert
            Assert.IsType<NotFoundResult>(actionResult);
        }

        [Fact]
        public async Task Not_found_result_if_parent_file()
        {
            //Arrange
            Directory.CreateDirectory(Path.Combine(_tempPath, "Web"));
            _hostingEnvironmentMock.SetupGet(x => x.WebRootPath).Returns(Path.Combine(_tempPath, "Web"));
            File.WriteAllText(Path.Combine(_tempPath, "1.png"), "<IMAGE>");

            //Act
            var picController = new PicController(_hostingEnvironmentMock.Object, null);
            var actionResult = picController.GetImage(@"..\1.png");

            //Assert
            Assert.IsType<NotFoundResult>(actionResult);
        }

        private CatalogModel GetFakeCatalog()
        {
            return new CatalogModel()
            {
                PageSize = 10,
                Count = 50,
                PageIndex = 2,
                Data = new List<CatalogItem>()
                {
                    new CatalogItem()
                    {
                        Id = "1",
                        Name = "fakeItemA",
                        CatalogTypeId = 1
                    },
                    new CatalogItem()
                    {
                        Id = "2",
                        Name = "fakeItemB",
                        CatalogTypeId = 1
                    },
                    new CatalogItem()
                    {
                        Id = "3",
                        Name = "fakeItemC",
                        CatalogTypeId = 1
                    }
                }
            };
        }
    }
}
