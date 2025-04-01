# Predict-State-Of-Charge-for-lithium-ion-batteries
Predict State Of Charge for lithium ion batteries using PINN for better accuracy with our own research 

![Typing SVG](https://readme-typing-svg.demolab.com/?lines=Welcome+to+my+project!+🚀)

![GitHub repo size](https://img.shields.io/github/repo-size/yugeshsivakumar/Predict-State-Of-Charge-for-lithium-ion-batteries)
![MIT license badge](https://img.shields.io/github/license/JanDeDobbeleer/oh-my-posh.svg)

## 📚TechStack

![My Skills](https://skillicons.dev/icons?i=git,github,md,matlab,py,sklearn,tensorflow,vscode)

![Matplotlib](https://img.shields.io/badge/Matplotlib-%23ffffff.svg?style=for-the-badge&logo=Matplotlib&logoColor=black) ![NumPy](https://img.shields.io/badge/numpy-%23013243.svg?style=for-the-badge&logo=numpy&logoColor=white) ![Pandas](https://img.shields.io/badge/pandas-%23150458.svg?style=for-the-badge&logo=pandas&logoColor=white)

## 🌲Project Structure

Here is the folder structure of this app.

```bash
Predict-State-Of-Charge-for-lithium-ion-batteries/
  |- Data_analysis_matlab/
    |-- Experimental_data_aged_cell.csv
    |-- Experimental_data_fresh_cell.csv
    |-- OCV_vs_SOC_curve.csv
    |-- SOC_SOH_extendend_model.m
    |-- SOC_SOH_simple_model.m
  |- PINN_Matlab/
    |-- 04-20-19_05.34 780_LA92_25degC_Turnigy_Graphene.mat
    |-- SOC_25deg.mlx
    |-- r0.mat
    |-- r1.mat
    |-- r2.mat
    |-- c0.mat
    |-- c1.mat
  |- Python/
    |-- Experimental_data_aged_cell.csv
    |-- Experimental_data_fresh_cell.csv
    |-- OCV_vs_SOC_curve.csv
    |-- SOC.ipynb
    |-- pinn.model.h5
  |- readme.md
  |- soc_vs_soh.md
  |- LICENSE
```

## ✅ Requirements

To run the notebooks, you'll need the following Python packages:

- `numpy`
- `pandas`
- `matplotlib`
- `tensorflow`
- `scikit-learn`
- `matlab`

You can install the required packages using pip:

```bash
pip install numpy pandas matplotlib seaborn scikit-learn tensorflow
```

## 🏃‍♂️‍➡️ How to Run

1. Clone this repository:

```bash
git clone https://github.com/yugeshsivakumar/Predict-State-Of-Charge-for-lithium-ion-batteries
```

2. Run 🏃‍♂️

```bash
1. Run jupyter notebook in Python folder for PINN VS Kalmann 
2. Run SOC_SOH_extendend_model.m or SOC_SOH_simple_model.m in matlab for data analysis
3. Run SOC_25deg.mlx on matlab for state of charge in 25deg prediction (PINN)
```

## 📩 Contact

Feel free to reach out to me:

**Contact Form**: https://forms.gle/gbnD57wG6oRVJ3aT8

**Project Link**: https://github.com/yugeshsivakumar/Predict-State-Of-Charge-for-lithium-ion-batteries

**Website**: https://yugesh.me

## 🌐 Links 

- **Our research paper**: 
- **Dataset_1**: https://data.mendeley.com/datasets/4fx8cjprxm/1
- **Dataset_2**: https://www.kaggle.com/datasets/pythonafroz/state-of-charge-and-state-of-health-of-batteries

## 🛂 Contributing
If you'd like to contribute to this project, please fork the repository and create a pull request with your proposed changes.

1. Fork the Project
    - Click on the 'Fork' button on the top right corner of this repository's page
   
2. Create your Feature Branch 
```bash
git checkout -b feature/AmazingFeature
```

3. Commit your Changes

```bash
git commit -m 'Add some AmazingFeature'
```

4. Push to the Branch

```bash
git push origin feature/AmazingFeature
```

5. Open a Pull Request
   - Go to your forked repository on GitHub and click on 'New Pull Request'.
   - Fill out the Pull Request form with details about your proposed changes.

## 🔑 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

