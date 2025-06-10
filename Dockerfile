# Imagen base para construir
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Copiar archivos de proyecto y restaurar dependencias
COPY *.csproj ./
RUN dotnet restore

# Copiar el resto del código y compilar
COPY . ./
RUN dotnet publish -c Release -o out

# Imagen base para runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/out .

# Puerto que expone la aplicación
EXPOSE 80

# Comando para arrancar la app
ENTRYPOINT ["dotnet", "AnalizadorOpiniones.dll"]