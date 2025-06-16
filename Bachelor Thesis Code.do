//This research is trying to investigate the effect of the green pass policy that had been implemented (from 2021q2 to 2022q1) in New York State on GDP, GDP in Private Industy, and also in which industries the effect of green pass policy is significant.
 
//The control states included are the states where this policy has been explicitly banned by the local governments.

//Here, the targeted specific industry of GDP is: GDP in Leisure and Hospitality industry (GDP_in_LH), it is retrieved by summing up the GDP of Accomodation, Food, Services and GDP of Arts, Entertainmenet, and Recreation.

// The other two selected industries are GDP in Retail Trade (GDP_in_RT) and GDP in Health care, social assistance (GDP_in_HCS)

//The first synthetic ccontrol is seeing the effect of the policy on GDP_in_All industries: with Index_QuantityChainType (an index caputuring level of production) and lnUnemployment_Level (the level of unemployment) as predictors, as well as all lagged outcome variables to capture the effects of changes

synth lnGDP_in_All Index_QuantityChainType lnTax_Collection lnUnemployment_Level lnGDP_in_All(`=tq(2019q1)') lnGDP_in_All(`=tq(2019q2)') lnGDP_in_All(`=tq(2019q3)') lnGDP_in_All(`=tq(2019q4)') lnGDP_in_All(`=tq(2020q1)') lnGDP_in_All(`=tq(2020q2)') lnGDP_in_All(`=tq(2020q3)') lnGDP_in_All(`=tq(2020q4)') lnGDP_in_All(`=tq(2021q1)'), trunit(10) trperiod(`=tq(2021q2)')  nested fig keep (results_synth) 

//The second SCM is used to see the effecct of the policy on GDO_in_Private industry

synth GDP_in_Pri Index_QuantityChainType lnTax_Collection lnUnemployment_Level GDP_in_Pri(`=tq(2019q1)') GDP_in_Pri(`=tq(2019q2)') GDP_in_Pri(`=tq(2019q3)') GDP_in_Pri(`=tq(2019q4)') GDP_in_Pri(`=tq(2020q1)') GDP_in_Pri(`=tq(2020q2)') GDP_in_Pri(`=tq(2020q3)') GDP_in_Pri(`=tq(2020q4)') GDP_in_Pri(`=tq(2021q1)'), trunit(10) trperiod(`=tq(2021q2)')  nested fig keep (results_synth) replace 

//Placebo Experiment with Florida
//Also, seeing the weight of state obtained (Texas 0.92 and Florida 0.08), the placebo experipent was conducted as well and there are no such big gaps for these two states.

drop if State == 10

synth GDP_in_Pri Index_QuantityChainType lnTax_Collection lnUnemployment_Level GDP_in_Pri(`=tq(2019q1)') GDP_in_Pri(`=tq(2019q2)') GDP_in_Pri(`=tq(2019q3)') GDP_in_Pri(`=tq(2019q4)') GDP_in_Pri(`=tq(2020q1)') GDP_in_Pri(`=tq(2020q2)') GDP_in_Pri(`=tq(2020q3)') GDP_in_Pri(`=tq(2020q4)') GDP_in_Pri(`=tq(2021q1)'), trunit(4) trperiod(`=tq(2021q2)')  nested fig keep (results_synth) 

Clear
