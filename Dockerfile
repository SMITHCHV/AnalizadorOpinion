# Imagen base para construir
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /app

# Copiar todo el contenido del proyecto al contenedor
COPY . ./

# Restaurar dependencias y publicar en modo Release
RUN dotnet restore
RUN dotnet publish AnalizadorOpiniones.csproj -c Release -o /app/out

# Imagen base para runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Copiar los archivos publicados desde la fase de build
COPY --from=build /app/out .

# Puerto que expone la aplicación
EXPOSE 80

# Comando para arrancar la app
ENTRYPOINT ["dotnet", "AnalizadorOpiniones.dll"]
