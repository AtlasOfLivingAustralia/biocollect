<style type="text/css">
.announcements th {
	white-space: normal;
}
</style>
<div data-bind="ifnot: details.status() == 'active'">
	<h4>Project Plan not available.</h4>
</div>

<div class="edit-view-meri-plan" data-bind="if: details.status() == 'active'">
	<span style="float:right;" data-bind="if:detailsLastUpdated">Last update date : <span data-bind="text:detailsLastUpdated.formattedDate"></span></span>
		<h3>Project Plan Information</h3>
		<div class="row-fluid space-after">
			    <div class="span6">
			        <div id="project-objectives" class="margin-bottom-10 margin-right-20">
			 			<label><b>Project Outcomes</b></label>
						<table class="outcome-targets table">
					        <thead>
					            <tr>
					            	<th class="index"></th>
									<th class="baseline">Baseline condition</th>
									<th class="target">Target Outcomes</th>
									<th class="assets">Asset(s) addressed</th>
					            </tr>
					        </thead>
						<tbody data-bind="foreach : details.objectives.rows1">
							<tr>
				            	<td class="index"><span data-bind="text: $index()+1"></span></td>
				            	<td class="baseline"><span data-bind="text:baseline"></span></td>
								<td class="target"><span data-bind="text:target"></span></td>
				            	<td class="assets"><label data-bind="text:assets"></label></td>
				            </tr>
						</tbody>		
						</table>	
						
						<table style="width: 100%;">
					        <thead>
					            <tr>
					            	<th></th>
					                <th>Monitoring indicator</th>
					                <th>Monitoring approach</th>
					            </tr>
					        </thead>
						<tbody data-bind="foreach : details.objectives.rows">
							<tr>
				            	<td><span data-bind="text: $index()+1"></span></td>
				            	<td><span data-bind="text:data1"></span></td>
				            	<td><label data-bind="text:data2"></label></td>
				            </tr>
						</tbody>		
						</table>			 			
			        </div>
			    </div>
			    <div class="span6">
		        <div id="project-partnership" class="margin-bottom-10 margin-right-20">
		 			<label><b>Project partnership</b></label>
		 			<table style="width: 100%;">
					        <thead>
					            <tr>
					            	<th></th>
					                <th>Partner name</th>
					                <th>Nature of partnership</th>
					                <th>Type of organisation</th>
					            </tr>
					        </thead>
						<tbody data-bind="foreach : details.partnership.rows">
							<tr>
				            	<td><span data-bind="text: $index()+1"></span></td>
				            	<td><span data-bind="text:data1"></span></td>
				            	<td><label data-bind="text:data2"></label></td>
				            	<td><label data-bind="text:data3"></label></td>
				            </tr>
						</tbody>		
					</table>			
		        </div>
	        </div>
		</div>
		
		<div class="row-fluid space-after">
		    <div class="span6">
		        <div id="project-implementation" class="margin-bottom-10 margin-right-20">
		 			<label><b>Project implementation / delivery mechanism</b></label>
		 			<span style="white-space: pre-wrap;" data-bind="text: details.implementation.description"> </span>
		        </div>
		    </div>
		    
		    <div class="span6">

		    </div>
		</div>


		<div class="row-fluid space-after">
			<div class="margin-bottom-10 margin-right-20">
 				<label><b>Key evaluation question</b></label>
	 			<table style="width: 100%;">
			        <thead>
			            <tr>
			            	<th></th>
			                <th>Project Key evaluation question (KEQ)</th>
			                <th>How will KEQ be monitored </th>
			            </tr>
			        </thead>
					<tbody data-bind="foreach : details.keq.rows">
						<tr>
			            	<td><span data-bind="text: $index()+1"></span></td>
			            	<td><span data-bind="text:data1"></span></td>
			            	<td><label data-bind="text:data2"></label></td>
			            </tr>
					</tbody>		
				</table>
			</div>
		</div>		
		
		<div class="row-fluid space-after">
			<div id="national-priorities" class="margin-bottom-10 margin-right-20">
	 			<label><b>National and regional priorities</b></label>
	 			<table style="width: 100%;">
			        <thead>
			            <tr>
			            	<th></th>
			                <th>Document name</th>
			                <th>Relevant section</th>
			                <th>Explanation of strategic alignment</th>
			            </tr>
			        </thead>
				<tbody data-bind="foreach : details.priorities.rows">
					<tr>
		            	<td><span data-bind="text: $index()+1"></span></td>
		            	<td><span data-bind="text: data1"></span></td>
		            	<td><label data-bind="text: data2"></label></td>
		            	<td><label data-bind="text: data3"></label></td>
		            </tr>
				</tbody>		
				</table>
			</div>
		</div>

		<g:if test="${user?.isAdmin}">
		<div class="row-fluid space-after">
			<div class="required">
				<div id="keq" class="margin-bottom-10 margin-right-20">
					<label><b>Project Budget</b></label>
					<table style="width: 100%;">
						<thead>
						<tr>
							<th width="2%"></th>
							<th width="12%">Investment/Priority Area</th>
							<th width="12%">Description</th>
							<!-- ko foreach: details.budget.headers -->
							<th style="text-align: center;" width="10%" ><div style="text-align: center;" data-bind="text:data"></div>$</th>
							<!-- /ko -->
							<th  style="text-align: center;" width="10%">Total</th>

						</tr>
						</thead>
						<tbody data-bind="foreach : details.budget.rows">
						<tr>
							<td><span data-bind="text:$index()+1"></span></td>
							<td><span style="width: 97%;" data-bind="text:shortLabel"> </span></td>
							<td><div style="text-align: left;"><span style="width: 90%;" data-bind="text: description"></span></div></td>

							<!-- ko foreach: costs -->
							<td><div style="text-align: center;"><span style="width: 90%;" data-bind="text: dollar.formattedCurrency"></span></div></td>
							<!-- /ko -->

							<td style="text-align: center;" ><span style="width: 90%;" data-bind="text: rowTotal.formattedCurrency"></span></td>

						</tr>
						</tbody>
						<tfoot>
						<tr>
							<td></td>
							<td></td>
							<td style="text-align: right;" ><b>Total </b></td>
							<!-- ko foreach: details.budget.columnTotal -->
							<td style="text-align: center;" width="10%"><span data-bind="text:data.formattedCurrency"></span></td>
							<!-- /ko -->
							<td style="text-align: center;"><b><span data-bind="text:details.budget.overallTotal.formattedCurrency"></span></b></td>
						</tr>
						</tfoot>
					</table>
				</div>
			</div>
		</div>
		</g:if>

		<g:if test="${projectContent.meriPlan.canViewRisks}">
		<!-- ko with: details -->
		<div class="row-fluid space-after">
			<div class="required">
			        <div id="project-risks-threats" class="margin-bottom-10 margin-right-20">
					<label><b>Project risks & threats</b></label> 
					<div align="right">
				  		<b> Overall project risk profile : <span data-bind="text: risks.overallRisk, css: overAllRiskHighlight" ></span></b>
					</div>
					<table style="width:100%;">
				    <thead >
			          <tr>
			            <th>Type of threat / risk</th>
			            <th>Description</th>
						<th>Likelihood</th>			                
						<th>Consequence</th>							
						<th>Risk rating</th>
						<th>Current control / Contingency strategy</th>														
						<th>Residual risk</th>	
			          </tr>
				    </thead>
					<tbody data-bind="foreach : risks.rows" >
					             <tr>
					                 <td>
					                 	<label data-bind="text: threat" ></label>
					                 </td>
					                 <td>
					                 	<label data-bind="text: description" ></label>
					                 </td>
					                 <td>
					                 	<label data-bind="text: likelihood" ></label>
					                 </td>
					                 <td>
					                 	<label data-bind="text: consequence" ></label>
					                 </td>
					                 <td>
					                 <label data-bind="text: riskRating" ></label> 
					                 </td>
					                 <td>
					                 	<label data-bind="text: currentControl" ></label>
					                  </td>
					                 <td>
					                 	<label data-bind="text: residualRisk" ></label>
					                  </td>
					              </tr>
					      </tbody>
					  </table>
		        </div>
			    </div>
		</div>
		<!-- /ko -->

			<!-- ko with: details.issues -->
			<div class="row-fluid space-after">
				<div class="required">
					<div class="project-issues margin-bottom-10 margin-right-20">
						<label><b>Project issues</b></label>
						<table style="width:100%;">
							<thead >
							<tr>
							<tr>
								<th class="type">Type of issue </th>
								<th class="status">Status </th>
								<th class="priority">Priority </th>
								<th class="description">Description</th>
								<th class="actionPlan">Action plan </th>
								<th class="impact">Impact</th>
							</tr>
							</tr>
							</thead>
							<tbody data-bind="foreach : issues" >
							<tr>
								<td class="type">
									<label data-bind="text: type" ></label>
								</td>
								<td class="status">
									<label data-bind="text: status" ></label>
								</td>
								<td class="priority">
									<label data-bind="text: priority" ></label>
								</td>
								<td  class="description">
									<label data-bind="text: description" ></label>
								</td>
								<td class="actionPlan">
									<label data-bind="text: actionPlan" ></label>
								</td>
								<td class="impact">
									<label data-bind="text: impact" ></label>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
				</div>
			</div>
			<!-- /ko -->
		</g:if>
</div>
