---
title: RPC over HTTP reaches end of support in Office 365 on October 31, 2017
description: Explains that RPC over HTTP in Office 365 will be deprecated on October 31, 2017. Contains information about why RPC over HTTP is being replaced by MAPI over HTTP and describes actions that Office 365 customers may have to take.
author: simonxjx
audience: ITPro
ms.prod: exchange-server-it-pro
ms.topic: article
ms.custom: CSSTroubleshoot
ms.author: v-six
manager: dcscontentpm
localization_priority: Normal
search.appverid: 
- MET150
appliesto:
- Exchange Online
- Outlook 2019
- Outlook 2016
- Outlook 2013
- Microsoft Outlook 2010
- Microsoft Office Outlook 2007
---

# RPC over HTTP reaches end of support in Office 365 on October 31, 2017

## Introduction 

As of Oct 31, 2017, RPC over HTTP will no longer be a supported protocol for accessing mail data from Exchange Online. Microsoft will no longer provide support or updates for Outlook clients that connect through RPC over HTTP, and the quality of the mail experience will decrease over time. 

RPC over HTTP is being replaced by MAPI over HTTP, a modern protocol that was launched in May 2014. This change affects you if you're running Outlook 2007 because Outlook 2007 won't work with MAPI over HTTP. To avoid being in an unsupported state, Outlook 2007 customers have to update to a newer version of Outlook or use Outlook on the web. 

This change may also affect you if you're running Outlook 2016, Outlook 2013, or Outlook 2010 because you must regularly check that the latest cumulative update for the version of Office that you have is installed. 

## References

For more information about MAPI over HTTP, see the following resources: 
- Microsoft Exchange Team Blog article: [Outlook Connectivity with MAPI over HTTP](https://blogs.technet.microsoft.com/exchange/2014/05/09/outlook-connectivity-with-mapi-over-http/).    
- Microsoft TechNet: [MAPI over HTTP](https://technet.microsoft.com/library/dn635177%28v=exchg.150%29.aspx) and [RPC over HTTP](https://technet.microsoft.com/library/bb123741%28v=exchg.150%29.aspx).    

