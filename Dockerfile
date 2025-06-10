# Etapa de build
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copiar todos los archivos
COPY . .

# Restaurar dependencias
RUN dotnet restore "AnalizadorOpiniones.csproj"

# Publicar
RUN dotnet publish "AnalizadorOpiniones.csproj" -c Release -o /app/publish

# Etapa de runtime
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

# Copiar salida publicada
COPY --from=build /app/publish .

EXPOSE 80
ENTRYPOINT ["dotnet", "AnalizadorOpiniones.dll"]
