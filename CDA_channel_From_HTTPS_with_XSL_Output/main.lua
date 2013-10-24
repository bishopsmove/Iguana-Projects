-- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.
-- Note: main() is the last function at the end of this code.

local cda = require 'cda'

require 'cda.xml'
require 'cda.null'
require 'cda.codeset'

local addElement = node.addElement
local setAttr = node.setAttr
local setInner = node.setInner
local setText = node.setText

-- Fill out empty attributes/elements in the header
-- all the values here are customer specific, you will
-- need to customise them to suit your requirements
local function FillHeader(CD)
   -- set the attributes
   CD.id.root = '2.16.840.1.113883.19.5.99999.2'
   CD.id.extension = 'TT998'
   CD.setId.root = '2.16.840.1.113883.19.7'
   CD.setId.extension = 'BB35'
   CD.versionNumber.value = 2   
   CD.languageCode.code = cda.codeset.language["English - US"]
   
   -- set the elements 
   setText(CD.title, 'Good Health Clinic Consultation Note')  
   cda.time.set{target=CD.effectiveTime, time='20070415000000+0500'}
   cda.code.set{target=CD.code, system=cda.codeset.cat.LOINC, 
      value=cda.codeset.loinc["Consultative note"], lookup=cda.codeset.loinc.reverse}
   cda.code.set{target=CD.confidentialityCode, system=cda.codeset.cat.Confidentiality, 
      value=cda.codeset.confidentiality['Normal'], lookup=cda.codeset.confidentiality.reverse}  

   return CD
end

local function FillPatient(RT)
   local function FillGuardian(G)
      cda.code.add{target=G, element='code', system=cda.codeset.cat["HL7 Role Class"],
         value=cda.codeset.personalRelationshipRole.Parent, lookup=cda.codeset.personalRelationshipRole.reverse}
      cda.demographic.address.add{target=G, use=cda.codeset.address.Home, 
         street='1357 Amber Drive', city='Beaverton', state='OR', zip='97867', country='US'}
      cda.demographic.phone.add{target=G, phone='(816)276-6909', use=cda.codeset.address.Home}
      local GP = addElement(G, 'guardianPerson')
      cda.demographic.name.add{target=GP, given='Ralph', family='Jones'}
      
      return G
   end
   
   local function FillBirthPlace(B)
      local P = addElement(B, 'place')
      cda.demographic.address.add{target=P, city='Beaverton', state='OR', zip='97867', country='US'}  
      
      return B
   end
   
   local function FillLanguageCommunication(L)
      cda.code.simple.add{target=L, element='languageCode', value=cda.codeset.language['English - US']}
      cda.code.add{target=L, element='modeCode', system=cda.codeset.cat["LanguageAbilityMode"],
         value=cda.codeset.proficiencyLevel["Good"], lookup=cda.codeset.proficiencyLevel.reverse}
      cda.value.add{target=L, element='preferenceInd', datatype='BL', value='true'}
      return L
   end
   
   local function FillProviderOrganization(O)
      cda.id.add{target=O, id_type=cda.codeset.cat["National Provider Identifier"]}
      cda.demographic.name.simple.add{target=O, name='Community Health and Hospitals'}
      cda.demographic.phone.add{target=O, phone='(555)555-5000', use=cda.codeset.address.Work}
      cda.demographic.address.add{target=O, use=cda.codeset.address.Work, 
         street='1001 Village Avenue', city='Beaverton', state='OR', zip='99123', country='US'}  
      
      return O
   end
   
   local PR = addElement(RT, 'patientRole')
   cda.id.add{target=PR, value='998991', id_type='2.16.840.1.113883.4.6'} -- dummy OID change or map value
   cda.id.add{target=PR, value='111-00-2330', id_type=cda.codeset.cat.SSN}
   cda.demographic.address.add{target=PR, use=cda.codeset.address.Home, street='1357 Amber Drive', 
      city='Beaverton', state='OR', zip='97867', country='US'} 
   cda.demographic.phone.add{target=PR, phone='(816)276-6909', use=cda.codeset.address.Home}  
   local P = addElement(PR, 'patient')
   cda.demographic.name.add{target=P, given='Isabella', nickname='Isa',
      family='Jones', use=cda.codeset.nameUses.Legal}
   cda.code.add{target=P, element='administrativeGenderCode', system=cda.codeset.cat["HL7 AdministrativeGender"], 
      value=cda.codeset.sex.Female, lookup=cda.codeset.sex.reverse}
   cda.time.add{target=P, element='birthTime', time='19750501000000+0500'}   
   cda.code.add{target=P, element='maritalStatusCode', system=cda.codeset.cat["HL7 Marital status"],
      value=cda.codeset.marriage.Married, lookup=cda.codeset.marriage.reverse}
   cda.code.add{target=P, element='religiousAffiliationCode', system=cda.codeset.cat.ReligiousAffiliation,
      value=cda.codeset.religion.Atheism, lookup=cda.codeset.religion.reverse}
   cda.code.add{target=P, element='raceCode', system=cda.codeset.cat["HL7 Race and Ethnicity"],
      value=cda.codeset.race.White, lookup=cda.codeset.race.reverse}
   cda.code.add{target=P, element='ethnicGroupCode', system=cda.codeset.cat["HL7 Race and Ethnicity"], 
      value=cda.codeset.ethnicGroup["Not Hispanic or Latino"], 
      lookup=cda.codeset.ethnicGroup.reverse}

   local G = addElement(P, 'guardian')
   FillGuardian(G)  
   local BP = addElement(P, 'birthplace')
   FillBirthPlace(BP)
   local LC = addElement(P, 'languageCommunication')
   FillLanguageCommunication(LC)
   local PO = addElement(PR, 'providerOrganization')
   FillProviderOrganization(PO)
   
   return RT
end

local function FillAuthor(A)
   cda.time.add{target=A, element='time', time='20070415000000+0500'}
   local AA = addElement(A, 'assignedAuthor')
   cda.id.add{target=AA, value='99999999', id_type=cda.codeset.cat["National Provider Identifier"]}
   cda.code.add{target=AA, element='code', system=cda.codeset.cat["Provider Codes"],
      value=cda.codeset.providerCodes["Allopathic &amp; Osteopathic Physicians"], 
      lookup=cda.codeset.providerCodes.reverse} 
   cda.demographic.address.add{target=AA, street='1002 Healthcare Drive', city='Portland', 
      state='OR', zip='99123', country='US'}  
   cda.demographic.phone.add{target=AA, phone='(555)555-1002', use=cda.codeset.address.Work} 
   local AP = addElement(AA, 'assignedPerson')
   cda.demographic.name.add{target=AP, given='Henry', family='Seven'}
   
   return A
end

local function FillCustodian(C)
   local AC = addElement(C, 'assignedCustodian')
   local O = addElement(AC, 'representedCustodianOrganization')
   cda.id.add{target=O, value='99999999', id_type=cda.codeset.cat["National Provider Identifier"]}
   cda.demographic.name.simple.add{target=O, name='Community Health and Hospitals'}
   cda.demographic.phone.add{target=O, phone='(555)555-1002', use=cda.codeset.address.Work} 
   cda.demographic.address.add{target=O, use=cda.codeset.address.Work, 
      street='1002 Healthcare Drive', city='Portland', state='OR', zip='99123', country='US'}  
   
   return C
end

local function FillEncounters(T)
   local function FillParticipant(Root)
      local P = addElement(Root, 'participant')
      local PR = addElement(P, 'participantRole')
      cda.id.template.add{target=PR, 
         id_type=cda.codeset.templates["Service Delivery Location"]}
      cda.code.add{target=PR, element='code', system=cda.codeset.cat["Healthcare Service Location"],
         value=cda.codeset.healthcareServiceLocation["Urgent Care Center"], 
         lookup=cda.codeset.healthcareServiceLocation.reverse}
      cda.demographic.address.add{target=PR, street='17 Daws Rd.', 
         city='Blue Bell', state='MA', zip='02368', country='US'}
      cda.null.set(cda.demographic.phone.add{target=PR}, cda.null.flavor.Unknown)
      local PE = addElement(PR, 'playingEntity')
      cda.demographic.name.simple.add{target=PE, name='Community Urgent Care Center'}
      setAttr(PE, 'classCode', 'PLC')
      setAttr(P, 'typeCode', 'LOC')
      setAttr(PR, 'classCode', 'SDLOC')
      
      return P
   end
   
   local function FillReason(Root)
      local ER = addElement(Root, 'entryRelationship')
      local OB = addElement(ER, 'observation')
      cda.id.template.add{target=OB, 
         id_type=cda.codeset.templates["Indication"]}
      cda.id.add{target=OB, value='45665', id_type='db734647-fc99-424c-a864-7e3cda82e703'}
      cda.code.add{target=OB, element='code', system=cda.codeset.cat.SNOMED_CT, 
         value=cda.codeset.snomedCT["Finding"], lookup=cda.codeset.snomedCT.reverse}
      cda.code.simple.add{target=OB, element='statusCode', value=cda.codeset.status['Completed']}
      cda.time.add{target=OB, element='effectiveTime', time='20070103000000+0500'}
      cda.code.add{target=OB, element='value', system=cda.codeset.cat.SNOMED_CT,
         value=cda.codeset.snomedCT["Pneumonia"], lookup=cda.codeset.snomedCT.reverse}  
      setAttr(setAttr(OB, 'classCode', 'OBS'), 'moodCode', 'EVN')     
      setAttr(ER, 'typeCode', 'RSON')
      
      return ER
   end
   
   local S = addElement(T, 'section')
   cda.id.template.add{target=S, 
      id_type=cda.codeset.templates["Encounters With Entries"]}
   cda.code.add{target=S, element='code', system=cda.codeset.cat.LOINC,
      value=cda.codeset.loinc["History of encounters"], lookup=cda.codeset.loinc.reverse}
   setText(addElement(S, 'title'), 'ENCOUNTERS')
   setInner(addElement(S, 'text'), [[
      <table border="1" width="100%">
          <thead>
              <tr>
                  <th>Encounter</th>
                  <th>Performer</th>
                  <th>Location</th>
                  <th>Date</th>
              </tr>
          </thead>
          <tbody>
              <tr>
                  <td>
                      <content ID="Encounter1"/> Checkup Examination </td>
                  <td>Performer Name</td>
                  <td>Community Urgent Care Center</td>
                  <td>20090227130000+0500</td>
              </tr>
          </tbody>
      </table>
      ]])   
   
   local E = addElement(S, 'entry')
   local EN = addElement(E, 'encounter')
   cda.id.template.add{target=EN, 
      id_type=cda.codeset.templates["Encounter Activities"]} 
   cda.id.add{target=EN, id_type='2a620155-9d11-439e-92b3-5d9815ff4de8'}
   local C = cda.code.add{target=EN, element='code', system=cda.codeset.cat.CPT, 
      value=cda.codeset.cpt["Office outpatient visit 15 minutes"], lookup=cda.codeset.cpt.reverse}
   setInner(addElement(C, 'originalText'), 'Checkup Examination <reference value="#Encounter1"/>')
   cda.code.add{target=C, element='translation', system=cda.codeset.cat["HL7 ActCode"], 
      value=cda.codeset.act["Ambulatory"], lookup=cda.codeset.act.reverse}
   setAttr(C, 'codeSystemVersion', '4')
   cda.time.add{target=EN, element='effectiveTime', time='20090227130000+0500'}
   local PERF = addElement(EN, 'performer')
   local AE = addElement(PERF, 'assignedEntity')
   cda.id.add{target=AE, id_type='PseudoMD-3'}
   cda.code.add{target=AE, element='code', system=cda.codeset.cat.SNOMED_CT,
      value=cda.codeset.snomedCT["General Physician"], lookup=cda.codeset.snomedCT.reverse}
   
   FillParticipant(EN)
   FillReason(EN)
   
   setAttr(setAttr(EN, 'classCode', 'ENC'), 'moodCode', 'EVN')
   setAttr(E, 'typeCode', 'DRIV')
   
   return T   
end

local function FillProblemList(T)
   local function FillStatus1(Root)
      local ER = addElement(Root, 'entryRelationship')
      local OB = addElement(ER, 'observation')
      cda.id.template.add{target=OB, 
         id_type=cda.codeset.templates["Problem Status Observation"]}
      cda.id.add{target=OB, id_type='ab1791b0-5c71-11db-b0de-0800200c9a66'}
      cda.code.add{target=OB, element='code', system=cda.codeset.cat.LOINC, 
         value=cda.codeset.loinc.Status, lookup=cda.codeset.loinc.reverse}
      setInner(addElement(OB, 'text'), '<reference value="#STAT1"/>')
      cda.code.simple.add{target=OB, element='statusCode', 
         value=cda.codeset.status['Completed']}
      local ET = cda.timerange.add{target=OB, element='effectiveTime'}
      cda.time.add{target=ET, element='low', time='20080103000000+0500'}
      cda.time.add{target=ET, element='high', time='20090227130000+0500'}
      cda.code.add{target=OB, element='value', system=cda.codeset.cat.SNOMED_CT,
         value=cda.codeset.snomedCT.Resolved, lookup=cda.codeset.snomedCT.reverse}    
      setAttr(setAttr(OB, 'classCode', 'OBS'), 'moodCode', 'EVN')
      setAttr(ER, 'typeCode', 'REFR') 
      
      return ER
   end
   
   local function FillAge1(Root)
      local ER = addElement(Root, 'entryRelationship')
      local OB = addElement(ER, 'observation')
      cda.id.template.add{target=OB, 
         id_type=cda.codeset.templates["Age Observation"]}
      cda.code.add{target=OB, element='code', system=cda.codeset.cat.SNOMED_CT, 
         value=cda.codeset.snomedCT["Age at onset"], lookup=cda.codeset.snomedCT.reverse}
      cda.code.simple.add{target=OB, element='statusCode', 
         value=cda.codeset.status['Completed']}
      cda.value.add{target=OB, element='value', datatype='PQ', value='57', unit='a'}    
      setAttr(setAttr(OB, 'classCode', 'OBS'), 'moodCode', 'EVN')
      setAttr(setAttr(ER, 'typeCode', 'SUBJ'), 'inversionInd', 'true') 
      
      return ER      
   end
   
   local function FillHealthStatus1(Root)
      local ER = addElement(Root, 'entryRelationship')
      local OB = addElement(ER, 'observation')
      cda.id.template.add{target=OB, 
         id_type=cda.codeset.templates["Health Status Observation"]}
      cda.code.add{target=OB, element='code', system=cda.codeset.cat.LOINC, 
         value=cda.codeset.loinc["Health Status"], lookup=cda.codeset.loinc.reverse}
      setInner(addElement(OB, 'text'), '<reference value="#problems"/>')
      cda.code.simple.add{target=OB, element='statusCode', 
         value=cda.codeset.status['Completed']}
      cda.code.add{target=OB, element='value', system=cda.codeset.cat.SNOMED_CT,
         value=cda.codeset.snomedCT["Alive and well"], lookup=cda.codeset.snomedCT.reverse}    
      setAttr(setAttr(OB, 'classCode', 'OBS'), 'moodCode', 'EVN')
      setAttr(ER, 'typeCode', 'REFR') 
      
      return ER      
   end
   
   local function FillProblem1(Root)
      local ER = addElement(Root, 'entryRelationship')
      local OB = addElement(ER, 'observation')
      cda.id.template.add{target=OB, 
         id_type=cda.codeset.templates["Problem Observation"]}
      cda.id.add{target=OB, id_type='ab1791b0-5c71-11db-b0de-0800200c9a66'}
      cda.code.add{target=OB, element='code', system=cda.codeset.cat.SNOMED_CT, 
         value=cda.codeset.snomedCT.Complaint, lookup=cda.codeset.snomedCT.reverse}
      setInner(addElement(OB, 'text'), '<reference value="#problem1"/>')
      cda.code.simple.add{target=OB, element='statusCode', 
         value=cda.codeset.status['Completed']}
      local ET = cda.timerange.add{target=OB, element='effectiveTime'}
      cda.time.add{target=ET, element='low', time='20080103000000+0500'}
      cda.time.add{target=ET, element='high', time='20080103000000+0500'}
      cda.code.add{target=OB, element='value', system=cda.codeset.cat.SNOMED_CT,
         value=cda.codeset.snomedCT.Pneumonia, lookup=cda.codeset.snomedCT.reverse}    
      
      FillStatus1(OB)
      FillAge1(OB)
      FillHealthStatus1(OB)
 
      setAttr(setAttr(OB, 'classCode', 'OBS'), 'moodCode', 'EVN')
      setAttr(ER, 'typeCode', 'SUBJ')  
      
      return ER
   end
   
   local function FillStatus2(Root)
      local ER = addElement(Root, 'entryRelationship')
      local OB = addElement(ER, 'observation')
      cda.id.template.add{target=OB, 
         id_type=cda.codeset.templates["Problem Status Observation"]}
      cda.id.add{target=OB, id_type='ab1791b0-5c71-11db-b0de-0800200c9a66'}
      cda.code.add{target=OB, element='code', system=cda.codeset.cat.LOINC, 
         value=cda.codeset.loinc.Status, lookup=cda.codeset.loinc.reverse}
      setInner(addElement(OB, 'text'), '<reference value="#STAT2"/>')
      cda.code.simple.add{target=OB, element='statusCode', 
         value=cda.codeset.status['Completed']}
      local ET = cda.timerange.add{target=OB, element='effectiveTime'}
      cda.time.add{target=ET, element='low', time='20080103000000+0500'}
      cda.time.add{target=ET, element='high', time='20090227130000+0500'}
      cda.code.add{target=OB, element='value', system=cda.codeset.cat.SNOMED_CT,
         value=cda.codeset.snomedCT.Active, lookup=cda.codeset.snomedCT.reverse}    
      setAttr(setAttr(OB, 'classCode', 'OBS'), 'moodCode', 'EVN')
      setAttr(ER, 'typeCode', 'REFR') 
      
      return ER
   end
   
   local function FillAge2(Root)
      local ER = addElement(Root, 'entryRelationship')
      local OB = addElement(ER, 'observation')
      cda.id.template.add{target=OB, 
         id_type=cda.codeset.templates["Age Observation"]}
      cda.code.add{target=OB, element='code', system=cda.codeset.cat.SNOMED_CT, 
         value=cda.codeset.snomedCT["Age at onset"], lookup=cda.codeset.snomedCT.reverse}
      cda.code.simple.add{target=OB, element='statusCode', 
         value=cda.codeset.status['Completed']}
      cda.value.add{target=OB, element='value', datatype='PQ', value='57', unit='a'}    
      setAttr(setAttr(OB, 'classCode', 'OBS'), 'moodCode', 'EVN')
      setAttr(setAttr(ER, 'typeCode', 'SUBJ'), 'inversionInd', 'true') 
      
      return ER      
   end
   
   local function FillHealthStatus2(Root)
      local ER = addElement(Root, 'entryRelationship')
      local OB = addElement(ER, 'observation')
      cda.id.template.add{target=OB, 
         id_type=cda.codeset.templates["Health Status Observation"]}
      cda.code.add{target=OB, element='code', system=cda.codeset.cat.LOINC, 
         value=cda.codeset.loinc["Health Status"], lookup=cda.codeset.loinc.reverse}
      setInner(addElement(OB, 'text'), '<reference value="#problems"/>')
      cda.code.simple.add{target=OB, element='statusCode', 
         value=cda.codeset.status['Completed']}
      cda.code.add{target=OB, element='value', system=cda.codeset.cat.SNOMED_CT,
         value=cda.codeset.snomedCT["Alive and well"], lookup=cda.codeset.snomedCT.reverse}    
      setAttr(setAttr(OB, 'classCode', 'OBS'), 'moodCode', 'EVN')
      setAttr(ER, 'typeCode', 'REFR') 
      
      return ER      
   end
   
   local function FillProblem2(Root)
      local ER = addElement(Root, 'entryRelationship')
      local OB = addElement(ER, 'observation')
      cda.id.template.add{target=OB, 
         id_type=cda.codeset.templates["Problem Observation"]}
      cda.id.add{target=OB, id_type='ab1791b0-5c71-11db-b0de-0800200c9a66'}
      cda.code.add{target=OB, element='code', system=cda.codeset.cat.SNOMED_CT, 
         value=cda.codeset.snomedCT.Complaint, lookup=cda.codeset.snomedCT.reverse}
      setInner(addElement(OB, 'text'), '<reference value="#problem2"/>')
      cda.code.simple.add{target=OB, element='statusCode', 
         value=cda.codeset.status['Completed']}
      local ET = cda.timerange.add{target=OB, element='effectiveTime'}
      cda.time.add{target=ET, element='low', time='20080103000000+0500'}
      cda.time.add{target=ET, element='high', time='20080103000000+0500'}
      cda.code.add{target=OB, element='value', system=cda.codeset.cat.SNOMED_CT,
         value=cda.codeset.snomedCT.Asthma, lookup=cda.codeset.snomedCT.reverse}    
      
      FillStatus2(OB)
      FillAge2(OB)
      FillHealthStatus2(OB)
 
      setAttr(setAttr(OB, 'classCode', 'OBS'), 'moodCode', 'EVN')
      setAttr(ER, 'typeCode', 'SUBJ')  
      
      return ER
   end
   
   local S = addElement(T, 'section')
   cda.id.template.add{target=S, 
      id_type=cda.codeset.templates["Problems With Entries"]}
   cda.code.add{target=S, element='code', system=cda.codeset.cat.LOINC, 
      value=cda.codeset.loinc["Problem list"], lookup=cda.codeset.loinc.reverse}
   setText(addElement(S, 'title'), 'PROBLEMS')
   setInner(addElement(S, 'text'), [[
      <content ID="problems"/>
      <list listType="ordered">
          <item>
              <content ID="problem1">Pneumonia </content>
              <content ID="stat1">Status: Resolved</content>
          </item>
          <item>
              <content ID="problem2">Asthma</content>
              <content ID="stat2">Status: Active</content>
          </item>
      </list>
      ]])
   
   local E = addElement(S, 'entry')
   local ACT = addElement(E, 'act')
   cda.id.template.add{target=ACT, 
      id_type=cda.codeset.templates["Problem Concern Act"]}
   cda.id.add{target=ACT, id_type='ec8a6ff8-ed4b-4f7e-82c3-e98e58b45de7'}      
   cda.code.add{target=ACT, element='code', system=cda.codeset.cat["HL7 Act Class"], 
      value=cda.codeset.actClass.concern, lookup=cda.codeset.actClass.reverse}      
   cda.code.simple.add{target=ACT, element='statusCode', value=cda.codeset.status['Completed']}
   local ET = cda.timerange.add{target=ACT, element='effectiveTime'}   
   cda.time.add{target=ET, element='low', time='20080103000000+0500'}
   cda.time.add{target=ET, element='high', time='20080103000000+0500'}
   
   FillProblem1(ACT)
   
   setAttr(setAttr(ACT, 'classCode', 'ACT'), 'moodCode', 'EVN')
   setAttr(E, 'typeCode', 'DRIV')
  
   E = addElement(S, 'entry')
   ACT = addElement(E, 'act')
   cda.id.template.add{target=ACT, 
      id_type=cda.codeset.templates["Problem Concern Act"]}
   cda.id.add{target=ACT, id_type='ec8a6ff8-ed4b-4f7e-82c3-e98e58b45de7'}      
   cda.code.add{target=ACT, element='code', system=cda.codeset.cat["HL7 Act Class"], 
      value=cda.codeset.actClass.concern, lookup=cda.codeset.actClass.reverse}      
   cda.code.simple.add{target=ACT, element='statusCode', value=cda.codeset.status['Completed']}
   ET = cda.timerange.add{target=ACT, element='effectiveTime'}   
   cda.time.add{target=ET, element='low', time='20080103000000+0500'}
   cda.time.add{target=ET, element='high', time='20080103000000+0500'}
   
   FillProblem2(ACT)
   
   setAttr(setAttr(ACT, 'classCode', 'ACT'), 'moodCode', 'EVN')
   setAttr(E, 'typeCode', 'DRIV')
   
   return T  
end

local ContentTypeMap = {
   ['.js']  = 'application/x-javascript',
   ['.css'] = 'text/css',
   ['.gif'] = 'image/gif',
   ['.xsl'] = 'text/xsl'
}

local function contentTypeFromFileName(FileName)
   local Ext = FileName:match('.*(%.%a+)$')
   if ContentTypeMap[Ext] then
      return ContentTypeMap[Ext]
   else
      return 'text/html'
   end
end

-- Serve up web docs (.css, .js files) from this project's "other" files.
local function serveWebDoc(Params)
   if Params.resource then
      local ResourcePath = 'other/'..Params.resource
      if iguana.project.files()[ResourcePath] then
         local F = io.open(iguana.project.files()[ResourcePath], 'rb')
         local WD = ((F and F:read('*a')) or nil)
         if F then F:close() end
         local T = contentTypeFromFileName(Params.resource)
         local HttpResponse = net.http.respond{entity_type=T, body=WD}
         iguana.logDebug(HttpResponse)
         return true
      else
         net.http.respond{entity_type='text/plain', body=
            'The URL requested was not found.', code=404}
      end
   end
   return false
end

function main(Data)
   
   queue.push{data=Data}
      
   local R = net.http.parseRequest{data=Data}
   
   trace(R)
   trace(R.params)
         
   if R.params ~= nil then
      if serveWebDoc(R.params) then return end
      end
   
   local Doc = cda.new()
   local CD = Doc.ClinicalDocument
   
    -- CDA Header 
   FillHeader(CD)
   local RT = CD:addElement('recordTarget')
   FillPatient(RT)
   local A = CD:addElement('author')
   trace(CD) -- view the new author element
   FillAuthor(A)
   local C = CD:addElement('custodian')
   FillCustodian(C)
   
   -- CDA Body
   local Body = CD:addElement('component')
   local SB = Body:addElement('structuredBody')
   local COM = SB:addElement('component')
   FillEncounters(COM)
   COM = SB:addElement('component')
   FillProblemList(COM)   
               
   net.http.respond{body='<?xml-stylesheet type="text/xsl" href="?resource=WebViewLayout_CDA.xsl"?>\n'..tostring(Doc),entity_type='text/xml'}
   
   -- TEST CODE: write CDA to file (in Iguana install dir)
   if iguana.isTest() then
      -- unformatted xml
      local f = io.open('cda_xml.xml','w+')
      f:write(tostring(Doc))
      f:close()
      -- formatted with xsl stylesheet
      f = io.open('cda_web.xml','w+')
      f:write('<?xml-stylesheet type="text/xsl" href="WebViewLayout_CDA.xsl"?>\n')
      f:write(tostring(Doc))
      f:close()
   end
end