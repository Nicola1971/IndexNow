/**
 * IndexNow
 *
 * IndexNow plugin
 *
 * @author    Nicola Lambathakis
 * @category    plugin
 * @version    1.6
 * @license	 http://www.gnu.org/copyleft/gpl.html GNU Public License (GPL)
 * @internal    @events OnDocFormSave,OnDocFormDelete
 * @internal    @installset base
 * @internal    @modx_category admin
 * @internal    @properties  &indexnow_key= IndexNow Key:;string; &indexnow_tvId= IndexNow TV ID:;string; &ResetTv= Reset IndexNow TV after sending:;list;yes,no;yes &exclude_docs=Exclude Documents by id (comma separated);string; &exclude_templates=Exclude Templates by id (comma separated);string; &Debug= Enable documents sent and errors logs:;list;yes,no;yes &DebugExcluded= Enable documents excluded logs:;list;yes,no;no
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
    if (!in_array($doc_id, $exclude_docs) && !in_array($template_id, $exclude_templates) && $indexnow_tvID == 1 && $published == 1) {
        // Valid document - send to IndexNow
$indexnow_key = isset($indexnow_key) ? $indexnow_key : '';

// Funzione per inviare una richiesta cURL a IndexNow
function sendToIndexNow($url) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch, CURLOPT_HEADER, 0);
    $output = curl_exec($ch);

    // Controllo se la richiesta cURL ha fallito
    if (curl_errno($ch)) {
        $error_msg = curl_error($ch);
        curl_close($ch);
        return ['status' => 'error', 'message' => 'Errore cURL: ' . $error_msg];
    }

    // Recupero le informazioni della richiesta
    $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    // Se la risposta è 202 (Accepted), restituisci un messaggio di successo
 if ($http_code == 200) {
        return ['status' => 'success', 'message' => 'IndexNow ha ricevuto la richiesta per l\'URL'];
    } else 
    if ($http_code == 202) {
        return ['status' => 'success', 'message' => 'IndexNow ha accettato la richiesta per l\'URL'];
    } else {
        return ['status' => 'error', 'message' => 'Errore nell\'invio a IndexNow. Codice HTTP: ' . $http_code];
    }
}

// Recupera l'ID del documento dall'evento
if (isset($id) && is_numeric($id)) {
    $pageId = $id;
} else {
    if ($Debug == 'yes') {
        $modx->logEvent(0, 3, 'ID documento non valido', 'IndexNow Plugin error');
    }
    return; // Ferma l'esecuzione se l'ID non è valido
}

// Ottieni l'URL della pagina modificata o creata
$pageUrl = $modx->makeUrl($pageId, '', '', 'full');

// Costruisci l'URL per IndexNow
$indexnow_url = "https://api.indexnow.org/indexnow?url=" . urlencode($pageUrl) . "&key=" . $indexnow_key;

// Quando una pagina viene salvata o eliminata, invia l'URL a IndexNow
switch ($modx->event->name) {
    case 'OnDocFormSave':
        // Invio della notifica a IndexNow per pagine create o aggiornate
        $responseIndexNow = sendToIndexNow($indexnow_url);

        // Controlla il risultato e logga il messaggio appropriato solo se il debug è abilitato
        if ($Debug == 'yes') {
            if ($responseIndexNow['status'] == 'success') {
                $modx->logEvent(0, 1, $responseIndexNow['message'] . ': ' . $pageUrl, 'IndexNow doc ID '.$doc_id.' success');
            } else {
                $modx->logEvent(0, 3, $responseIndexNow['message'], 'IndexNow Plugin fail');
            }
        }
        break;

    case 'OnDocFormDelete':
        // Invio della notifica a IndexNow per pagine eliminate
        $responseIndexNow = sendToIndexNow($indexnow_url);

        // Controlla il risultato e logga il messaggio appropriato solo se il debug è abilitato
        if ($Debug == 'yes') {
            if ($responseIndexNow['status'] == 'success') {
                $modx->logEvent(0, 1, $responseIndexNow['message'] . ' per l\'eliminazione della pagina: ' . $pageUrl, 'IndexNow Plugin success');
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
				$indexnow_tvvalue ='active';
			} else {
                $indexnow_tvvalue ='inactive';
            }
			$pageUrl = $modx->makeUrl($doc_id, '', '', 'full');
			
            $modx->logEvent(0, 2, "$pageUrl escluso da IndexNow. INFO: DOC ID: $doc_id Template ID: $template_id, TV ID $indexnow_tvId \"$tv_name\" is $indexnow_tvvalue", 'IndexNow - doc ID '.$doc_id.' excluded');
        }
    }
    
	// Resetta il valore della TV, cancellando il suo valore esistente (o impostando un valore predefinito)
	if ($ResetTv == 'yes') {
    $reset_value = '';  // Vuoto per resettare

    // Controlla se esiste già un valore per quella TV e documento
    $result = $modx->db->getValue($modx->db->select('id', $modx->getFullTableName('site_tmplvar_contentvalues'), "contentid = $doc_id AND tmplvarid = $indexnow_tvId"));

    if ($result) {
        // Se esiste un valore, lo aggiorniamo per resettarlo
        $modx->db->update(array('value' => $reset_value), $modx->getFullTableName('site_tmplvar_contentvalues'), "contentid = $doc_id AND tmplvarid = $indexnow_tvId");
    } else {
        // Se non esiste un valore, inserisci un nuovo record con il valore resettato
        $modx->db->insert(array(
            'tmplvarid' => $indexnow_tvId,
            'contentid' => $doc_id,
            'value' => $reset_value
        ), $modx->getFullTableName('site_tmplvar_contentvalues'));
    }
	}	
}