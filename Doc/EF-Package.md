Microsoft.EntityFrameworkCore.Design
https://learn.microsoft.com/en-gb/ef/core/get-started/overview/first-app?tabs=netcore-cli

Install:

dotnet tool install --global dotnet-ef
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet ef migrations add InitialCreate
dotnet ef database update