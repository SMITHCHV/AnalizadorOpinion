# Etapa 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copiar archivos del proyecto
COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o /out

# Etapa 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Copiar archivos compilados
COPY --from=build /out ./

# Exponer el puerto (Render detectará el 10000 si no lo fuerzas)
EXPOSE 10000

# Variables de entorno necesarias para ML.NET en Linux
ENV DOTNET_EnableDiagnostics=0
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false
ENV LC_ALL=en_US.UTF-8

ENTRYPOINT ["dotnet", "AnalizadorOpinion.dll"]
