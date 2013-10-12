<?php

/**
 * Sencha Animator to Gloo Converter
 *
 * Revision History
 * 1.4  Sep 27 2013  LLL  added convertImgSrcAttributes() - see comments
 * 1.3  Aug 01 2013  CAB
 * 1.2  Jul 30 2013  CAB  Ported to PHP-CLI, will not work on the web.
 *                        Usage: php converter.php index.html gloo_assets_202/ appletMyApplet/scaledAssets/scaleDir/ ASPECT_FIT 200
 *                                                 ^ exported ^ organization   ^ path to images                      ^ ratio    ^ stage margin 
 * 1.1  Jun 20 2013  LLL  added support for Sencha Animator 1.5
 *                        removed 'function!' replacement security work-around
 * 1.0  Jun 07 2013  LLL  added code to make Sencha Animator controller object global
 */

$sa2gcDescription='Sencha Animator to Gloo Converter';
$sa2gcVersion='1.4';

// Set default timezone
date_default_timezone_set('America/Los_Angeles');

// open file (read entire contents into string)
$inpfildta = file_get_contents($argv[1]);

// read Sencha Animator version string
$verstr = getVersionString($inpfildta);

// validate Sencha Animator version string
if(!validateVersion($verstr)) { exit(1); }

// phase 1: strip HTML wrapper
$outfildta = stripHtmlWrapper($inpfildta);

// phase 2: replace all 'assets/' relative paths with substitute
$outfildta = replaceAssetPaths($outfildta, $argv[2] . $argv[3]);

// phase 3: convert <img> 'src' attributes to 'data-src' attributes
$outfildta = convertImgSrcAttributes($outfildta);

// phase 4: insert JS code
$outfildta = insertJavascriptCode($outfildta, $argv[2], $argv[4], $argv[5], $verstr);

// phase 5: modify Sencha Animator JS
$outfildta = modifySenchaAnimatorCode($outfildta);

// phase 6: wrap with comments
$outfildta = wrapWithComments($outfildta);

// output file for display
echo $outfildta;

// done!

// -------------------- ERROR FUNCTIONS --------------------

function echoErrorAndExit($errtxt)
{
  echoError($errtxt);
  exit(1);
}

function echoError($errtxt)
{
  echoIncomingFileDetails();
  echo "<br>";
  echo "Error: " . $errtxt . "<br>";
}

function echoIncomingFileDetails()
{
  echo "Upload: " . $_FILES["file"]["name"] . "<br>";
  echo "Extension: " . end(explode(".", $_FILES["file"]["name"])) . "<br>";
  echo "Type: " . $_FILES["file"]["type"] . "<br>";
  echo "Size: " . ($_FILES["file"]["size"] / 1024) . " kB<br>";
}

// -------------------- PARSING FUNCTIONS --------------------

/**
 * Gets the version string from the incoming Sencha Animator file
 * Terminates the program with an error if no version string is found
 *
 * Returns: the version string, i.e. '1.3', '1.5'
 */
function getVersionString($dta)
{
  // search for version/build tokens
  $vertkn = '<!-- Sencha Animator Version: ';       // version token
  $veridx = strpos($dta,$vertkn);
  $bldidx = strpos($dta,'Build: ');                 // build token
  
  // check if tokens were found
  if($veridx===FALSE || $bldidx===FALSE) {
    echoErrorAndExit('Could not read Sencha Animator version from input file');
  }

  // isolate version string
  $stridx = $veridx + strlen($vertkn);
  $verstr = trim( substr($dta,$stridx,$bldidx-$stridx) ); // trim whitespace from both ends
  return $verstr;
}

/**
 * Validates the Sencha Animator version string
 * Returns: TRUE if valid, FALSE otherwise
 */
function validateVersion($verstr)
{
  // check version string
  if($verstr=='1.3' || $verstr=='1.5') { return TRUE; /* version OK */ }

  // invalid
  echoError('Invalid Sencha Animator version [' . $verstr . ']');
  return FALSE;
}

/**
 * Strip HTML header, footer, body tags
 * Returns: the stripped string
 */
function stripHtmlWrapper($dta)
{
  // 1) strip everything before the first '<script'
  $begpos=strpos($dta,'<script');
  if($begpos===FALSE) { echoErrorAndExit('script tag not found'); }
  $dta=substr($dta,$begpos);

  // 2) delete middle snippet: </head><body ... up until <div id=
  $begpos=strpos($dta,'</head>');
  $endpos=strpos($dta,'<div id=');
  if($begpos===FALSE || $endpos===FALSE) { echoErrorAndExit('head/body tags not found'); }
  $dta=substr($dta,0,$begpos) . substr($dta,$endpos);

  // 3) delete ending snippet: </body></html>
  $begpos=strpos($dta,'</body>');
  if($begpos===FALSE) { echoErrorAndExit('closing body tag not found'); }
  $dta=substr($dta,0,$begpos);

  return $dta;
}

/**
 * Replace all 'asset/' path values with the new asset path value
 * Returns: the modified string
 */
function replaceAssetPaths($dta, $newpth)
{
  return str_replace('assets/',$newpth,$dta);
}

/**
 * Convert <img> 'src' attributes to 'data-src' attributes
 * Note: this will prevent unwanted 404s when the page is first loaded and the real src has not been written yet
 * Returns: the modified string
 */
function convertImgSrcAttributes($dta)
{
  // search and replace src=" with data-src=" only if it's preceeded by an <img tag and there are no other < or > chars between <img and src="

  // regex explanation: match <img, any char except < or > 0-n times, a space, and finally src="
  //                    the \K resets the match start, so only src=" will be replaced
  //                    \K was used instead of a lookbehind assertion because it handles variable length patterns
  return preg_replace('/<img[^<>]* \Ksrc="/','data-src="',$dta);
}

/**
 * Insert jQuery and custom scaling and asset selection JS code
 *
 * dta      file data string
 * bseurl   base URL for assets
 * sclmod   scale mode
 * stgmgn   stage margin
 * verstr   version string
 *
 * Returns: the modified string
 */
function insertJavascriptCode($dta, $bseurl, $sclmod, $stgmgn, $verstr)
{
  // append <script> tags
  return $dta . "\n\n" .
    '<script src="' . $bseurl . 'shared/js/jquery-2.0.0.min.js"></script>' . "\n" .
    '<script src="' . $bseurl . 'shared/js/saUtility.js"></script>' . "\n" .
    '<script type="text/javascript">' . "\n" .
    '  $(function(){ saUtility.setConfig({ ' .
          'scaleMode: saUtility.SCALE_MODE.'  . $sclmod . ', ' .
          'stageMargin: '                     . $stgmgn . ', ' .
          'saVersion: '                       . $verstr .
          ' }); });' . "\n" .
    '  $(window).load(function(){ saUtility.revealAnimation(); });' . "\n" .
    '</script>' . "\n";
}

/**
 * Modify Sencha Animator JS code
 * Returns: the modified string
 */
function modifySenchaAnimatorCode($dta)
{
  // make Sencha Animator controller object global
  $schstr="controller.setConfig(configData);"; // search string
  $begpos=strpos($dta,$schstr);
  if($begpos===FALSE) { echoErrorAndExit('controller config line not found'); }
  $begpos+=strlen($schstr);
  // insert new line
  $dta=substr($dta,0,$begpos) . "window.saController=controller;/* make the controller global */" . substr($dta,$begpos);
  return $dta;
}

/**
 * Wrap some simple comments around the output data
 * Returns: the modified string
 */
function wrapWithComments($dta)
{
  global $sa2gcDescription, $sa2gcVersion;

  $datcmt = '<!-- ' . $sa2gcDescription . ' ' . $sa2gcVersion . ' : ' . date(DATE_RFC822) . ' -->';

  return $datcmt . "\n" .
         $dta    . "\n" .
         $datcmt . "\n";
}

?>