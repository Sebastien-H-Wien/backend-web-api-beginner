
FROM mcr.microsoft.com/dotnet/sdk:9.0@sha256:3fcf6f1e809c0553f9feb222369f58749af314af6f063f389cbd2f913b4ad556 AS build
WORKDIR /App

# Copy everything
COPY ["BackendWebAPIBeginner.csproj", "./"]
# Restore as distinct layers
RUN dotnet restore "BackendWebAPIBeginner.csproj"

# Build
COPY [".", "./"]
RUN dotnet build "BackendWebAPIBeginner.csproj" -c Release -o /App/build


#Publish
FROM build AS publish
RUN dotnet publish "BackendWebAPIBeginner.csproj" -c Release -o /App/publish

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0@sha256:b4bea3a52a0a77317fa93c5bbdb076623f81e3e2f201078d89914da71318b5d8
ENV ASPNETCORE_HTTP_PORTS=5195
EXPOSE 5195
WORKDIR /App
COPY --from=publish /App/publish .
# ENTRYPOINT ["dotnet", "DotNet.Docker.dll"]
ENTRYPOINT ["dotnet", "BackendWebAPIBeginner.dll"]


# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

################################################################################

# Learn about building .NET container images:
# https://github.com/dotnet/dotnet-docker/blob/main/samples/README.md

# Create a stage for building the application.
# FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
#
# COPY . /source
#
# WORKDIR /source
#
# # This is the architecture you’re building for, which is passed in by the builder.
# # Placing it here allows the previous steps to be cached across architectures.
# ARG TARGETARCH
#
# # Build the application.
# # Leverage a cache mount to /root/.nuget/packages so that subsequent builds don't have to re-download packages.
# # If TARGETARCH is "amd64", replace it with "x64" - "x64" is .NET's canonical name for this and "amd64" doesn't
# #   work in .NET 6.0.
# RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages \
#     dotnet publish -a ${TARGETARCH/amd64/x64} --use-current-runtime --self-contained false -o /app
#
# # If you need to enable globalization and time zones:
# # https://github.com/dotnet/dotnet-docker/blob/main/samples/enable-globalization.md
# ################################################################################
# # Create a new stage for running the application that contains the minimal
# # runtime dependencies for the application. This often uses a different base
# # image from the build stage where the necessary files are copied from the build
# # stage.
# #
# # The example below uses an aspnet alpine image as the foundation for running the app.
# # It will also use whatever happens to be the most recent version of that tag when you
# # build your Dockerfile. If reproducibility is important, consider using a more specific
# # version (e.g., aspnet:7.0.10-alpine-3.18),
# # or SHA (e.g., mcr.microsoft.com/dotnet/aspnet@sha256:f3d99f54d504a21d38e4cc2f13ff47d67235efeeb85c109d3d1ff1808b38d034).
# FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS final
# WORKDIR /app
#
# # Copy everything needed to run the app from the "build" stage.
# COPY --from=build /app .
#
# # Switch to a non-privileged user (defined in the base image) that the app will run under.
# # See https://docs.docker.com/go/dockerfile-user-best-practices/
# # and https://github.com/dotnet/dotnet-docker/discussions/4764
# USER $APP_UID
#
# ENTRYPOINT ["dotnet", "BackendWebAPIBeginner.dll"]
