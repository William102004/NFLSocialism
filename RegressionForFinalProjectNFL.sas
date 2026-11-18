/*Import Data*/
FILENAME REFILE '/home/u64421955/Data_sets/regression_data.csv';
proc import datafile= REFILE Replace
	 DBMS=CSV
	 OUT=NFLstats;
	 getnames=Yes; 
	 guessingrows=max;
run;

/*Print Data head*/
proc print data=NFLstats (obs = 10);
run;

/*Data Exploration*/

/*Correlation and Simple Statistics*/
proc corr data=NFLstats;
	 var win_loss_perc log_pop draft_capital_3yr rel_payroll prior_win_pct;
run;


proc stdize data=NFLstats out=NFLz method=std oprefix=raw_;
    var log_pop rel_payroll draft_capital_3yr prior_win_pct;
run;

/*Run Regression Model*/
proc reg data=NFLz;
	model win_loss_perc = log_pop draft_capital_3yr rel_payroll prior_win_pct/VIF CLB;
run;

/*Initial model vs Market Size*/
proc surveyreg data=NFLz;
    cluster franchise;
    model win_loss_perc = log_pop / solution clparm;
run;

/*final model*/
proc surveyreg data=NFLz;
    cluster franchise;
    model win_loss_perc = log_pop rel_payroll draft_capital_3yr prior_win_pct / solution clparm;
    ods output ParameterEstimates=coef FitStatistics=fit;
run;

/* Model 3: did the team make the playoffs? (logistic regression) */
proc surveylogistic data=NFLz;
    cluster franchise;
    model made_playoffs(event='1') = log_pop rel_payroll draft_capital_3yr prior_win_pct;
run;

/* Save coefficients */
proc export data=coef outfile='/home/u64421955/Data_sets/coef.csv' dbms=csv replace;
run;