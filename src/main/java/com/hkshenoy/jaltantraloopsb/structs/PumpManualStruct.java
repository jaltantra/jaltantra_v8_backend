package com.hkshenoy.jaltantraloopsb.structs;
//container for manual pump information

//pipeid: pipe id of the pipe in which pump is installed
//pumppower: power of the pump in kW
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties(ignoreUnknown = true)
public class PumpManualStruct
{
	public PumpManualStruct() {
	}

	public PumpManualStruct(int pipeid, double pumppower) {
		this.pipeid = pipeid;
		this.pumppower = pumppower;
	}

	public int pipeid;
	public double pumppower;
	
	@Override
	public String toString() {
		return "EsrCostStruct [pipeid=" + pipeid + ", pumppower="
				+ pumppower + "]";
	}
}
