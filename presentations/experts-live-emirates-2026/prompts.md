# Experts Live Emirates 2026 - demo prompts

## 1. Pre-flight - connect and show the connection status

```text
Using the PnP PowerShell MCP server, run a pre-flight check in three steps and report back after each step.

STEP 1. Check the environment: is pwsh available, is the PnP.PowerShell module installed and current enough, and is this session already connected? If it is, as which account and to which URL?

STEP 2. If the session is not connected, connect to the tenant admin site. The connection parameters are in environment/.env in this workspace and use certificate authentication. Do not print the client ID, tenant ID or certificate thumbprint in your answer.

STEP 3. Prove the connection with a real round trip to the service: run Get-PnPWeb and show me the Url and Title that come back. Then give me the connection status as a short summary: the URL, the connection method and the tenant. Stay connected, because the next prompts reuse this session.
```

## 2. List all the external users in the tenant

```text
Using the PnP PowerShell MCP server and the tenant admin connection from the pre-flight, find and list all the external users in the tenant. Search for the right cmdlet first rather than assuming one, and page through all of the results rather than stopping at the first page. Show me the UPN, display name and the date they were invited, and tell me how many there are in total. This step is read-only. Do not change anything.
```

## 3. Export the external users to CSV

```text
Now export all of those external users to a CSV file at output/external-users.csv in this workspace. Reuse the results from the previous step if you still have them, otherwise fetch them again the same way. Include the columns you showed me (UPN, display name, and the date they were invited). Write UTF-8 without a type information header and overwrite the file if it already exists. Then tell me the full path and how many rows you wrote. Nothing in the tenant should change.
```

## 4. Top ten sites by storage

```text
Using the same tenant admin connection, find the ten site collections in the tenant that use the most storage. Search for the right cmdlet first rather than assuming one, and leave out OneDrive sites. For each of the ten sites, show the URL, title, template, storage used in MB, storage quota in MB, and the percentage of the quota used, sorted by storage used with the largest first. Then tell me the total storage used across all sites in the tenant. This step is read-only. Do not change anything in the tenant.
```

## 5. Owners of group-connected sites

```text
Using the same tenant admin connection, list every site collection in the tenant that is connected to a Microsoft 365 group, together with the owners of that group. Search for the right cmdlets first rather than assuming them, and leave out OneDrive sites. For each site, show the URL, the title, the group name, and the owners' display names. Mark the sites whose group has only one owner, and tell me how many group-connected sites there are in total and how many have a single owner. This step is read-only. Do not change anything.
```

## 6. Which sites have external sharing enabled?

```text
Which sites have external sharing enabled? First get the tenant-level sharing setting, because it caps what any single site can allow. Then list every site collection whose sharing setting is anything other than disabled, leaving out OneDrive sites. Group them by sharing level, from most to least open: anyone links, new and existing guests, existing guests only. Show the URL, title and sharing level for each site, and tell me how many sites are in each group. This step is read-only. Do not change anything.
```

## 7. Create the Karak Café managed metadata

```text
Using the PnP PowerShell MCP server and the connection from the pre-flight, set up the managed metadata for the Karak Café lists. In the term store, create a term group called "Karak Café" with these three term sets and terms:

- Menu Categories: Karak & Tea, Arabic Coffee, Specialty Coffee, Sweets, Savouries
- Allergens: Gluten, Milk, Egg, Nuts, Sesame, Soy
- Café Locations: Sharjah - SPARK, Sharjah - Al Majaz, Dubai - Marina, Dubai - DIFC, Abu Dhabi - Corniche

Search for the right cmdlets first rather than assuming them. Check what already exists before creating anything, reuse it, and never create duplicates. Then show me the term group with each term set and its terms.
```

## 8. Create the Karak Café lists

```text
Using the PnP PowerShell MCP server, connect to the demo site from environment/.env and provision two SharePoint lists from the JSON definitions in listDefinitions: first karak-cafe-menu.json, then karak-cafe-orders.json. Create every list, site column, list column and view exactly as the JSON declares, and bind the managed metadata columns to the Karak Café term sets from the previous step. Respect the dependency order. Report what you created.
```
