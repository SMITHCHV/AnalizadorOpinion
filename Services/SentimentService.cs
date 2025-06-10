using Microsoft.ML;
using AnalizadorOpiniones.MLModels;
using System;
using System.IO;

namespace AnalizadorOpiniones.Services
{
    public class SentimentService
    {
        private readonly string _modelPath = Path.Combine("MLModels", "sentiment_model.zip");
        private readonly string _dataPath = Path.Combine("Data", "sentiment-data.tsv");

        private readonly MLContext _mlContext = new();
        private readonly PredictionEngine<SentimentData, SentimentPrediction> _predictionEngine;

        public SentimentService()
        {
            Console.WriteLine($"[INFO] Buscando modelo en: {_modelPath}");

            if (File.Exists(_modelPath))
            {
                Console.WriteLine("[INFO] Modelo encontrado. Cargando...");
                var loadedModel = _mlContext.Model.Load(_modelPath, out _);
                _predictionEngine = _mlContext.Model.CreatePredictionEngine<SentimentData, SentimentPrediction>(loadedModel);
            }
            else
            {
                Console.WriteLine("[WARN] Modelo no encontrado. Entrenando nuevo modelo...");
                _predictionEngine = TrainModel();
            }
        }

        private PredictionEngine<SentimentData, SentimentPrediction> TrainModel()
        {
            if (!File.Exists(_dataPath))
                throw new FileNotFoundException($"[ERROR] No se encontró el archivo de datos en: {_dataPath}");

            var dataView = _mlContext.Data.LoadFromTextFile<SentimentData>(_dataPath, hasHeader: true);
            var pipeline = _mlContext.Transforms.Text.FeaturizeText("Features", nameof(SentimentData.Text))
                .Append(_mlContext.BinaryClassification.Trainers.SdcaLogisticRegression(labelColumnName: "Label", featureColumnName: "Features"));

            var model = pipeline.Fit(dataView);
            _mlContext.Model.Save(model, dataView.Schema, _modelPath);
            Console.WriteLine("[INFO] Modelo entrenado y guardado.");

            return _mlContext.Model.CreatePredictionEngine<SentimentData, SentimentPrediction>(model);
        }

        public SentimentPrediction Predict(string inputText)
        {
            Console.WriteLine($"[INFO] Analizando texto: {inputText}");
            return _predictionEngine.Predict(new SentimentData { Text = inputText });
        }
    }
}
