# BERSERI

> Machine Learning-Based Skin Analysis and Skincare Ingredient Recommendation

BERSERI is a mobile skincare analysis application that helps users understand their skin type and visible skin conditions through facial image analysis and a short questionnaire.

The application uses Machine Learning for image-based skin analysis and a rule-based recommendation system to provide general skincare ingredient recommendations based on the user's analysis results.

## Overview

Choosing suitable skincare ingredients can be difficult because users may not fully understand their skin type or visible skin conditions. BERSERI aims to provide a simple way for users to perform basic skin analysis through a mobile device.

BERSERI combines:

- Facial image analysis
- Skin type classification
- Visible skin condition classification
- User questionnaire
- Rule-based ingredient recommendations

> **Note:** BERSERI is designed for general skincare reference and education. It is not a medical diagnostic application.

## Main Features

### Skin Analysis

Users can capture or upload a facial image and perform an analysis.

The analysis consists of:

- Skin type classification
- Visible skin condition detection
- Skincare questionnaire
- Final skin type determination

### Skin Type Classification

BERSERI classifies skin into four categories:

- Normal
- Dry
- Oily
- Combination

The initial image-based prediction is combined with the questionnaire result to determine the user's final skin type.

### Skin Condition Classification

BERSERI detects visible skin conditions using a multi-label classification approach.

Supported conditions:

- Acne
- Acne Scars
- Hyperpigmentation
- Wrinkles
- Redness

Multiple conditions can be detected from a single analysis.

### Skincare Ingredient Recommendation

Based on the final skin type and detected conditions, BERSERI provides general skincare ingredient recommendations.

The recommendation system is **rule-based**, not generated directly by the Machine Learning model.

### Analysis History

Users can view previous analysis results, including:

- Analysis date
- Skin type
- Detected skin conditions
- Recommended ingredients

### Ingredient Library

Users can explore information about skincare ingredients, including:

- Ingredient name
- General skincare purpose
- Suitable skin types or conditions
- Usage considerations
