#!/usr/bin/env python3
"""
Heart Rate Model Training Script
Trains a TensorFlow model for heart rate estimation from PPG signal data.
"""

import numpy as np
import tensorflow as tf
from tensorflow import keras
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class HeartRateModelTrainer:
    """Trainer for heart rate estimation model."""
    
    def __init__(self, input_size=300, num_classes=1):
        """Initialize trainer.
        
        Args:
            input_size: Number of samples per PPG signal
            num_classes: Output classes (1 for regression)
        """
        self.input_size = input_size
        self.num_classes = num_classes
        self.model = None
        self.scaler = StandardScaler()
    
    def build_model(self):
        """Build the neural network model."""
        logger.info("Building heart rate model...")
        
        inputs = keras.Input(shape=(self.input_size, 1))
        
        # First Conv block
        x = keras.layers.Conv1D(64, 3, activation='relu', padding='same')(inputs)
        x = keras.layers.BatchNormalization()(x)
        x = keras.layers.MaxPooling1D(2)(x)
        
        # Second Conv block
        x = keras.layers.Conv1D(128, 3, activation='relu', padding='same')(x)
        x = keras.layers.BatchNormalization()(x)
        x = keras.layers.MaxPooling1D(2)(x)
        
        # Third Conv block
        x = keras.layers.Conv1D(256, 3, activation='relu', padding='same')(x)
        x = keras.layers.BatchNormalization()(x)
        x = keras.layers.MaxPooling1D(2)(x)
        
        # Global average pooling
        x = keras.layers.GlobalAveragePooling1D()(x)
        
        # Dense layers
        x = keras.layers.Dense(128, activation='relu')(x)
        x = keras.layers.Dropout(0.5)(x)
        x = keras.layers.Dense(64, activation='relu')(x)
        x = keras.layers.Dropout(0.3)(x)
        
        # Output layer (heart rate: 40-200 bpm)
        outputs = keras.layers.Dense(1, activation='linear')(x)
        
        model = keras.Model(inputs=inputs, outputs=outputs)
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='mse',
            metrics=['mae']
        )
        
        logger.info(f"Model created with {model.count_params()} parameters")
        self.model = model
        return model
    
    def generate_synthetic_data(self, num_samples=1000):
        """Generate synthetic PPG data for training.
        
        Args:
            num_samples: Number of training samples to generate
            
        Returns:
            Tuple of (X, y) where X is signals and y is heart rates
        """
        logger.info(f"Generating {num_samples} synthetic PPG samples...")
        
        X = []
        y = []
        
        for _ in range(num_samples):
            # Random heart rate between 40-200 bpm
            true_hr = np.random.uniform(40, 200)
            
            # Generate PPG signal with fundamental frequency at HR
            sampling_rate = 30  # Hz
            duration = self.input_size / sampling_rate
            t = np.linspace(0, duration, self.input_size)
            
            # PPG signal components
            freq_hz = true_hr / 60  # Convert bpm to Hz
            
            # Fundamental frequency (heart rate)
            signal = 0.8 * np.sin(2 * np.pi * freq_hz * t)
            
            # Low frequency drift
            signal += 0.3 * np.sin(2 * np.pi * 0.1 * t)
            
            # High frequency noise
            signal += 0.1 * np.random.normal(0, 1, self.input_size)
            
            # Add some respiration component
            signal += 0.15 * np.sin(2 * np.pi * 0.25 * t)
            
            X.append(signal)
            y.append(true_hr)
        
        X = np.array(X, dtype=np.float32)
        y = np.array(y, dtype=np.float32)
        
        # Reshape for Conv1D (samples, timesteps, channels)
        X = X.reshape(-1, self.input_size, 1)
        
        logger.info(f"Data shape: X={X.shape}, y={y.shape}")
        return X, y
    
    def train(self, X, y, epochs=100, batch_size=32, validation_split=0.2):
        """Train the model.
        
        Args:
            X: Training signals
            y: Training labels (heart rates)
            epochs: Number of training epochs
            batch_size: Batch size
            validation_split: Validation split ratio
        """
        if self.model is None:
            self.build_model()
        
        logger.info("Starting training...")
        
        # Split data
        X_train, X_val, y_train, y_val = train_test_split(
            X, y, test_size=validation_split, random_state=42
        )
        
        # Callbacks
        callbacks = [
            keras.callbacks.EarlyStopping(
                monitor='val_loss',
                patience=10,
                restore_best_weights=True
            ),
            keras.callbacks.ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=5,
                min_lr=1e-7
            )
        ]
        
        # Train model
        history = self.model.fit(
            X_train, y_train,
            validation_data=(X_val, y_val),
            epochs=epochs,
            batch_size=batch_size,
            callbacks=callbacks,
            verbose=1
        )
        
        logger.info("Training completed")
        return history
    
    def evaluate(self, X_test, y_test):
        """Evaluate model on test data.
        
        Args:
            X_test: Test signals
            y_test: Test labels
            
        Returns:
            Tuple of (loss, mae)
        """
        if self.model is None:
            raise ValueError("Model not trained")
        
        loss, mae = self.model.evaluate(X_test, y_test)
        logger.info(f"Test Loss: {loss:.4f}, Test MAE: {mae:.4f}")
        return loss, mae
    
    def save_model(self, path='models/heart_rate_model.h5'):
        """Save trained model.
        
        Args:
            path: Save path for the model
        """
        if self.model is None:
            raise ValueError("Model not trained")
        
        self.model.save(path)
        logger.info(f"Model saved to {path}")
    
    def convert_to_tflite(self, output_path='models/heart_rate_model.tflite'):
        """Convert trained model to TensorFlow Lite format.
        
        Args:
            output_path: Output path for TFLite model
        """
        if self.model is None:
            raise ValueError("Model not trained")
        
        logger.info("Converting to TensorFlow Lite...")
        
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        
        tflite_model = converter.convert()
        
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        logger.info(f"TFLite model saved to {output_path}")
    
    def predict(self, signal):
        """Predict heart rate from PPG signal.
        
        Args:
            signal: PPG signal (1D array)
            
        Returns:
            Predicted heart rate (bpm)
        """
        if self.model is None:
            raise ValueError("Model not trained")
        
        # Reshape for model input
        signal = np.array(signal, dtype=np.float32)
        if signal.ndim == 1:
            signal = signal.reshape(1, -1, 1)
        elif signal.ndim == 2:
            signal = signal.reshape(signal.shape[0], -1, 1)
        
        prediction = self.model.predict(signal, verbose=0)
        return prediction[0, 0]


def main():
    """Main training pipeline."""
    logger.info("Starting heart rate model training...")
    
    # Initialize trainer
    trainer = HeartRateModelTrainer(input_size=300)
    
    # Generate synthetic data
    X, y = trainer.generate_synthetic_data(num_samples=1000)
    
    # Build model
    trainer.build_model()
    
    # Train model
    trainer.train(X, y, epochs=50, batch_size=32)
    
    # Split data for final evaluation
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Evaluate
    trainer.evaluate(X_test, y_test)
    
    # Save models
    trainer.save_model('models/heart_rate_model.h5')
    trainer.convert_to_tflite('models/heart_rate_model.tflite')
    
    # Test prediction
    test_signal = X_test[0]
    predicted_hr = trainer.predict(test_signal)
    actual_hr = y_test[0]
    logger.info(f"Sample prediction: {predicted_hr:.1f} bpm (actual: {actual_hr:.1f} bpm)")
    
    logger.info("Training complete!")


if __name__ == '__main__':
    main()
