/**
 * IndexNow
 *
 * IndexNow plugin
 *
 * @author Nicola Lambathakis http://www.tattoocms.it/ https://github.com/Nicola1971/
 * @category    plugin
 * @version    1.7
 * @license	 http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnDocFormSave,OnDocFormDelete
 * @internal    @installset base
 * @internal    @modx_category SEO
 * @internal    @properties  &indexnow_key= IndexNow Key:;string; &SendMode= Manual / Automatic sending:;list;manual,auto;manual &indexnow_tvId= IndexNow TV ID (manual mode):;string; &ResetTv= Reset IndexNow TV after sending (manual mode):;list;yes,no;yes &exclude_docs=Exclude Documents by id (comma separated);string; &exclude_templates=Exclude Templates by id (comma separated);string; &Debug= Enable documents sent and errors logs:;list;yes,no;yes &DebugExcluded= Enable documents excluded logs:;list;yes,no;no
 * @internal    @disabled 0
 * @lastupdate  25-09-2024
 * @documentation Requirements: This plugin requires Evolution 1.4 or later
 * @documentation https://github.com/Nicola1971/IndexNow/
 * @reportissues https://github.com/Nicola1971/IndexNow/issues
 */
if (!defined('MODX_BASE_PATH')) {
    die('What are you doing? Get out of here!');
}

global $modx;

// Get the list of excluded document and template IDs
$exclude_docs = explode(',', $exclude_docs);
$exclude_templates = explode(',', $exclude_templates);

// Check if the event is OnDocFormSave or OnDocFormDelete
if ($modx->event->name == 'OnDocFormSave' || $modx->event->name == 'OnDocFormDelete') {
    $doc_id = $id; // The $id parameter is the document ID being saved or deleted
    $template_id = $modx->db->getValue($modx->db->select('template', $modx->getFullTableName('site_content'), "id=$doc_id"));
    $published = $modx->db->getValue($modx->db->select('published', $modx->getFullTableName('site_content'), "id=$doc_id"));
//get indexnow tv name and value
	$tv_name = $modx->db->getValue($modx->db->select('name', $modx->getFullTableName('site_tmplvars'), "id = $indexnow_tvId"));
	$indexnow_tv = $modx->getTemplateVarOutput($tv_name,$doc_id);
	$indexnow_tvID = $indexnow_tv[$tv_name];
    // Check if the document should be excluded
	$VarindexTv = ($SendMode == 'manual') ? ($indexnow_tvID == 1) : true;
	if ($VarindexTv && $published == 1  && !in_array($doc_id, $exclude_docs) && !in_array($template_id, $exclude_templates)) {
// Valid document - send to IndexNow
$indexnow_key = isset($indexnow_key) ? $indexnow_key : '';

// Function to send a cURL request to IndexNow
function sendToIndexNow($url) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    $output = curl_exec($ch);

    // Check if cURL request failed
    if (curl_errno($ch)) {
        $error_msg = curl_error($ch);
        curl_close($ch);
        return ['status' => 'error', 'message' => 'Errore cURL: ' . $error_msg];
    }

    // Retrieve request information
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    // If the response is 202 (Accepted), return a success message
 if ($http_code == 200) {
        return ['status' => 'success', 'message' => 'IndexNow has received the request for the URL'];
    } else 
    if ($http_code == 202) {
        return ['status' => 'success', 'message' => 'IndexNow has accepted the request for the URL'];
    } else {
        return ['status' => 'error', 'message' => 'Error sending to IndexNow. HTTP Code: ' . $http_code];
    }
}

// Retrieve the document ID from the event
if (isset($id) && is_numeric($id)) {
    $pageId = $id;
} else {
    if ($Debug == 'yes') {
        $modx->logEvent(0, 3, 'Invalid document ID', 'IndexNow Plugin error');
    }
    return; // Stop if ID is invalid
}

// Get the URL of the modified or created page
$pageUrl = $modx->makeUrl($pageId, '', '', 'full');

// Build URL for IndexNow
$indexnow_url = "https://api.indexnow.org/indexnow?url=" . urlencode($pageUrl) . "&key=" . $indexnow_key;

// When a page is saved or deleted, send the URL to IndexNow
switch ($modx->event->name) {
    case 'OnDocFormSave':
        // Sending notification to IndexNow for created or updated pages
        $responseIndexNow = sendToIndexNow($indexnow_url);

        // Check the result and log the appropriate message only if debugging is enabled
        if ($Debug == 'yes') {
            if ($responseIndexNow['status'] == 'success') {
                $modx->logEvent(0, 1, $responseIndexNow['message'] . ': ' . $pageUrl, 'IndexNow doc ID '.$doc_id.' success - Send Mode: ' . $SendMode . '');
            } else {
                $modx->logEvent(0, 3, $responseIndexNow['message'], 'IndexNow Plugin fail');
            }
        }
        break;

    case 'OnDocFormDelete':
        // Sending notification to IndexNow for deleted pages
        $responseIndexNow = sendToIndexNow($indexnow_url);

        // Check the result and log the appropriate message only if debugging is enabled
        if ($Debug == 'yes') {
            if ($responseIndexNow['status'] == 'success') {
                $modx->logEvent(0, 1, $responseIndexNow['message'] . ' for deleting the page: ' . $pageUrl, 'IndexNow Plugin success - Send Mode: ' . $SendMode . '');
            } else {
                $modx->logEvent(0, 3, $responseIndexNow['message'], 'IndexNow Plugin error');
            }
        }
        break;
}
    } else {
        // Document is excluded or not valid
        if ($DebugExcluded == 'yes') {
			if ($indexnow_tvID == 1) {
				$indexnow_tvvalue ='send';
			} else {
                $indexnow_tvvalue ='do not send';
            }
			$pageUrl = $modx->makeUrl($doc_id, '', '', 'full');
			
            $modx->logEvent(0, 2, "$pageUrl <b>excluded and not sent by IndexNow</b>. <br/> <br/>  <h3>MORE INFO</h3> <br/> <b>Send Mode:</b> $SendMode<br/><b>DOC ID:</b> $doc_id<br/><b>Template ID:</b> $template_id <br/><b>TV \"$tv_name\" </b>(ID $indexnow_tvId) is set to <b>$indexnow_tvvalue</b>", 'IndexNow Plugin - doc ID '.$doc_id.' excluded and not sent');
        }
    }
    
	// If the confirmation is positive and ResetTv is active Reset the TV value
	if ($ResetTv == 'yes' || $responseIndexNow['status'] == 'success') {
    $reset_value = '';  // Empty to reset

    // Check if there is already a value for that TV and document
    $result = $modx->db->getValue($modx->db->select('id', $modx->getFullTableName('site_tmplvar_contentvalues'), "contentid = $doc_id AND tmplvarid = $indexnow_tvId"));

    if ($result) {
        // If there is a value, we update it to reset it
        $modx->db->update(array('value' => $reset_value), $modx->getFullTableName('site_tmplvar_contentvalues'), "contentid = $doc_id AND tmplvarid = $indexnow_tvId");
    } else {
        // If there is no value, insert a new record with the reset value
        $modx->db->insert(array(
            'tmplvarid' => $indexnow_tvId,
            'contentid' => $doc_id,
            'value' => $reset_value
        ), $modx->getFullTableName('site_tmplvar_contentvalues'));
    }
	}	
}