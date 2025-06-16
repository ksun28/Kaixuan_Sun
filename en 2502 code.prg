close @all

' ** Ensure the prg file is in the same directory as your data **
%path = "/Users/sunkaixuan/Desktop/Career/SARB/Research Supply and Demand Driven Inflation"
cd %path

' ** Import data **
import "retail_sales_source.xlsx" range=index_q colhead=1 na="#N/A" @freq M @id @date(series01) @destid @date @smpl @all
import "retail_sales_source.xlsx" range=index_p colhead=1 na="#N/A" @freq M @id @date(series01) @destid @date @smpl @all
import "retail_sales_source.xlsx" range=weights colhead=1 na="#N/A" @freq M @id @date(series01) @destid @date @smpl @all
delete series01 

'****************************CHANGE YEARLY****************************************
pagestruct(end=2024)																		'*
'******************************************************************************************

' ** Grouping all the variables together ** 
group quantities _*
group deflators p_*
group weights w_*

' **Calculating RTS inflation rates**
group rts_inf
for !i=1 to deflators.@count
%name = deflators.@seriesname(!i)
series inf_{%name} = ({%name}/{%name}(-12) - 1)*100
rts_inf.add inf_{%name}
next
series headline_inflation = (headline/headline(-12) - 1)*100
series rts_inflation = (retail_deflator/retail_deflator(-12) - 1)*100
series core_inflation = (core_goods/core_goods(-12) - 1)*100
group headline_rts headline_inflation core_inflation rts_inflation

' ** Running the VARs**
for !i=1 to deflators.@count  																' Specify that we need run the loop over each variable
%name_p = deflators.@seriesname(!i)
%name_q = quantities.@seriesname(!i)
%name = quantities.@seriesname(!i)
%group_name = "resid" + quantities.@seriesname(!i)
var var{%name}.ls 1 12 log({%name_p}) log({%name_q})  										
var{%name}.makeresids rp{%name} rq{%name}
group {%group_name}  rp{%name} rq{%name}										
next

' ** Positive/negative demand and supply shocks: expenditure shares **
group dpos
group dpos_w
for !i=1 to deflators.@count
%name = quantities.@seriesname(!i)
series dpos{%name} = @recode(rp{%name}>0 and rq{%name}>0, 1, 0)
series dpos{%name}_w = dpos{%name} * w{%name}
dpos.add dpos{%name}
dpos_w.add dpos{%name}_w
next
series demand_positive= @rsum(dpos_w)	

group dneg
group dneg_w
for !i=1 to deflators.@count
%name = quantities.@seriesname(!i)
series dneg{%name} = @recode(rp{%name}<0 and rq{%name}<0, 1, 0)
series dneg{%name}_w = dneg{%name} * w{%name}
dneg.add dneg{%name}
dneg_w.add dneg{%name}_w
next
series demand_negative= @rsum(dneg_w)	

group spos
group spos_w
for !i=1 to deflators.@count
%name = quantities.@seriesname(!i)
series spos{%name} = @recode(rp{%name}<0 and rq{%name}>0, 1, 0)
series spos{%name}_w = spos{%name} * w{%name}
spos.add spos{%name}
spos_w.add spos{%name}_w
next
series supply_positive= @rsum(spos_w)	

group sneg
group sneg_w
for !i=1 to deflators.@count
%name = quantities.@seriesname(!i)
series sneg{%name} = @recode(rp{%name}>0 and rq{%name}<0, 1, 0)
series sneg{%name}_w = sneg{%name} * w{%name}
sneg.add sneg{%name}
sneg_w.add sneg{%name}_w
next
series supply_negative= @rsum(sneg_w)

group weight_check demand_positive demand_negative supply_positive supply_negative
series weightcheck =@rsum(weight_check)

' ** RTS inflation decomposition **
group supply_drivers
group supply_driven
for !i=1 to deflators.@count
%name = quantities.@seriesname(!i)
series supply_drivers{%name} = @recode((rp{%name}>0 and rq{%name}<0) or (rp{%name}<0 and rq{%name}>0), 1, 0)
series supply_driven{%name} = supply_drivers{%name} * (w{%name}/100) * inf_p{%name}
supply_drivers.add supply_drivers{%name}
supply_driven.add supply_driven{%name}
next
series inflation_supply_driven= @rsum(supply_driven)

group demand_drivers
group demand_driven
for !i=1 to deflators.@count
%name = quantities.@seriesname(!i)
series demand_drivers{%name} = @recode((rp{%name}>0 and rq{%name}>0) or (rp{%name}<0 and rq{%name}<0), 1, 0)
series demand_driven{%name} = demand_drivers{%name} * (w{%name}/100) * inf_p{%name}
demand_drivers.add demand_drivers{%name}
demand_driven.add demand_driven{%name}
next
series inflation_demand_driven= @rsum(demand_driven)

' ** Moving averages to smooth volatility (note: Since it is a centred moving avg, this function does not yield a value for the latest quarter; take avg of the latest and previous quarter in Excel to get an approximation of the latest quarter's 3qcma value)**
series rts_inflation_3qcma = @movavc(rts_inflation,3) '@movavc(series,period)
series inflation_demand_driven_3qcma = @movavc(inflation_demand_driven,3)
series inflation_supply_driven_3qcma = @movavc(inflation_supply_driven,3)

' ** Moving relevant results to a separate page**
pagecopy(dataonly, nolinks, page=Final_results, wf=DEMAND_SUPPLY_SOURCE) headline_inflation rts_inflation  inflation_demand_driven inflation_supply_driven demand_positive demand_negative supply_positive supply_negative rts_inflation_3qcma inflation_demand_driven_3qcma inflation_supply_driven_3qcma
group rts_inflation_contributions rts_inflation  inflation_demand_driven inflation_supply_driven
group rts_inflation_contributions_3qcma rts_inflation_3qcma rts_inflation  inflation_demand_driven_3qcma inflation_supply_driven_3qcma
group shocks_shares  demand_positive demand_negative supply_positive supply_negative
rts_inflation_contributions_3qcma.mixed stackedbar(3,4) line(1,2)
rts_inflation_contributions.mixed stackedbar(2,3) line(1)

