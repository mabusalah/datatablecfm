<!--- 
Code:			Coldfusion Server Side For Datatables
Environemnt:	Datatables 1.10.16, Lucee 5.x, Postgres 9.6
License:		GPL v2
Issue Date:		04/10/2017
Notes:			There is no warranty that the code will work on a different environment or different version.
!--->
<!--- Variables --->
<cfset dataSource= 'wiki'>
<cfset dataTable= 'datatables_demo'> <!--- You may create the DB table using the postgres.sql script included with Datatables server_side examples --->
<cfset tableFields= ['first_name','last_name','position','office','start_date','salary','age','extn','email','seq']>
<cfset noOfTableFields = ArrayLen(tableFields)>
<cfset searchFields= ['first_name','last_name','position','office']>
<cfset noOfSearchFields = ArrayLen(searchFields)>
<cfparam name='url.draw' default='' type="string">
<cfparam name='url.start' default='0' type="integer">
<cfparam name='url.length' default='10' type="integer">
<cfparam name="url['search[value]']" default='' type="string">
<cfparam name="url['order[0][column]']" default='0' type="string">
<cfparam name="url['order[0][dir]']" default='asc' type="string">
<cfset start= Int(Val(URL.start))>
<cfset length= Int(Val(URL.length))>
<cfset search= Trim(url['search[value]'])>
<cfset iSortCol_0= Int(Val(URL['order[0][column]']))>
<cfif LCase(URL['order[0][dir]']) EQ 'asc'>
	<cfset sSortDir_0='asc'>
<cfelse>
	<cfset sSortDir_0='desc'>
</cfif>
<cfset queryWhere="">
<cfif (search NEQ '')> 
    <cfset queryWhere ="where (">
    <cfloop from="1"  to="#noOfSearchFields#" index="counter">
      <cfset queryWhere=queryWhere &" lower(#searchFields[counter]#) LIKE '%#Lcase(search)#%' ">
      <cfif counter LT noOfSearchFields>
      	<cfset queryWhere=queryWhere&" OR">
	  </cfif>
    </cfloop>
    <cfset queryWhere=queryWhere&")">
</cfif>
<cfif iSortCol_0 NEQ 0>
	<cfset queryOrder='ORDER BY #tableFields[iSortCol_0 + 1]# #sSortDir_0#'>
<cfelse>
	<cfset queryOrder=''>
</cfif>
<cfif length NEQ 0>
	<cfset queryLimit='OFFSET #start# LIMIT #length#'>
<cfelse>
	<cfset queryLimit=''>
</cfif>
<cfquery name="queryResult" datasource="#datasource#">
	select #ArrayToList(tableFields)# FROM #dataTable# #PreserveSingleQuotes(queryWhere)# #queryOrder# #queryLimit#
</cfquery>
<cfquery name="querycount" datasource="#datasource#">
	select count(*) OVER() AS total FROM #dataTable# #PreserveSingleQuotes(queryWhere)# #queryOrder# #queryLimit#
</cfquery>
<cfsavecontent variable="datatablesjson">
        <cfloop from="1"  to="#queryResult.RecordCount#" index="counter">
        <cfoutput>
            [
            <cfloop from="1"  to="#noOfTableFields#" index="innerCounter">
                <cfif tableFields[innerCounter] EQ "start_date">
                    "#JSStringFormat(dateformat(queryResult[tableFields[innerCounter]][counter],'yyyy/mm/dd'))#"
                <cfelse>
                    "#JSStringFormat(queryResult[tableFields[innerCounter]][counter])#"
                </cfif>
                <cfif innerCounter LT noOfTableFields>
                    ,
                </cfif>
            </cfloop>
            ]
            <cfif counter LT queryResult.RecordCount>
                ,
            </cfif>        
        </cfoutput>
        </cfloop>
</cfsavecontent>
    <cfif queryResult.RecordCount is 0>
    	<cfset datatablesjson=' [ '>
    	<cfloop from="1" to="#noOfTableFields#" index="counter">
    		<cfset datatablesjson=datatablesjson&'"Empty"'>
			<cfif counter LT noOfTableFields>
            	<cfset datatablesjson=datatablesjson&' , '>
            </cfif>
    	</cfloop>
        <cfset datatablesjson=datatablesjson&' ] '>
    </cfif>
<cfoutput>
{
    "draw": #Int(Val(URL.draw))#,
    "recordsTotal": <cfif querycount.total GT 0>#querycount.total#<cfelse>0</cfif>,
    "recordsFiltered": <cfif querycount.total GT 0>#querycount.total#<cfelse>0</cfif>,   
    "data": [#datatablesjson#]
}
</cfoutput>