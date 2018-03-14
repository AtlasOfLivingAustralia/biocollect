<div data-bind="ifnot: details.status() == 'active'">
	<h4>Project Plan not available.</h4>
</div>

<div class="edit-view-meri-plan" data-bind="if: details.status() == 'active'">
	<span style="float:right;" data-bind="if:detailsLastUpdated">Last updated <span data-bind="if:detailsLastUpdatedDisplayName"> by <span data-bind="text:detailsLastUpdatedDisplayName"></span></span> at <span data-bind="text:detailsLastUpdated.formattedDate"></span></span>
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
					            	<th>	</th>
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
				<g:render template="budgetTableReadOnly"/>
			</div>
		</div>
		</g:if>

		<g:if test="${projectContent.meriPlan.canViewRisks}">
		<!-- ko with: details -->
		<div class="row-fluid space-after">
			<div class="required">
			    <g:render template="riskTableReadOnly"/>
			</div>
		</div>
		<!-- /ko -->

			<!-- ko with: details.issues -->
			<div class="row-fluid space-after">
				<div class="required">
					<g:render template="issueTableReadOnly"/>
				</div>
			</div>
			<!-- /ko -->
		</g:if>
</div>
