/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

public with sharing class ISVConsoleHelper {
   


public static void AddFieldToObjectsMap(String fieldName, String initialObjectName, Map<String, Set<String>> theMap)
    {
        if (fieldName.contains('.')) // than it is a parent-relationship field
                { 
                    String relName1 = fieldName.substringBefore('.');
                    String relField1 = fieldName.substringAfter('.');
                    if (relField1.contains('.')) // than it is a 2 level parent-relationship field
                    {
                       String relName2 = relField1.substringBefore('.');
                       String relField2 = relField1.substringAfter('.');
                       
                        // Check if it is a custom relationship field
                        if (relName2.contains('__r')) // than it is a custom relationship
                        {
                            // Object name is the field name replacing "__r" for "__c"
                            String objectName2 = relName2.replace('__r', '__c');
                            AddFieldToMap(relField2, objectName2, theMap);
                        }
                        else // than it is a standard relationship field
                        {
                            // get the standard object name from a list of values (example: Ownerid = User)
                        }
                        
                    }
                    else // than it is a 1 level parent-relationship field
                    {
                        // Check if it is a custom relationship field
                        if (relName1.contains('__r')) // than it is a custom relationship
                        {
                            // Object name is the field name replacing "__r" for "__c"
                            String objectName1 = relName1.replace('__r', '__c');
                            AddFieldToMap(relField1, objectName1, theMap);
                        }
                        else // than it is a standard relationship field
                        {
                            // get the standard object name from a list of values (example: Ownerid = User)
                        }
                        
                    }
                    
                    
                }
        else
			AddFieldToMap(fieldName, initialObjectName, theMap);
        
    }




private static void AddFieldToMap(String fieldName, String ObjectName, Map<String, Set<String>> theMap)
    {
        // Check if object name is already on the map of objects and fields 
        if (theMap.containsKey(ObjectName)) // if it is, add the field to the set of field names for the object
            {
                Set<String> existingFieldSet = theMap.get(ObjectName);
                existingFieldSet.add(fieldName);
                theMap.put(ObjectName, existingFieldSet);
            }
        else // if not, add the object name and the field name to the map
        {
            Set<String> newFieldSet = new Set<String>();
            newFieldSet.add(fieldName);
            theMap.put(ObjectName, newFieldSet);
        }
        
    }

public static boolean UserHasAccessToObjectsAndFields(Map<String, Set<String>> theMap)
{
	Boolean hasAccess = true;

	if (theMap.size() > 0)
        {
            System.debug('######## theMap: ' + theMap);
            for (String objectName: theMap.keySet())
            {
                System.debug('######## objectName: ' + objectName);
                SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject() ;
                Map<String,Schema.SObjectField> m = sObj.getSobjectType().getDescribe().fields.getMap();
                Set<String> objectFieldSet = theMap.get(objectName);
                
                for (String fieldToCheck : objectFieldSet) {
    				System.debug('######## fieldToCheck: ' + fieldToCheck);
                    // Check if the user has access to view field
                    if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
            			System.debug('######## User does not have access to field: ' + fieldToCheck);
                        // Pass error to client
                        hasAccess = false;
                        throw new System.NoAccessException();
            
                    }
                    System.debug('######## User has access to field: ' + fieldToCheck);
                }
                
            }
            
        }

        return hasAccess;
}
}