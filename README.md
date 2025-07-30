# File Structure

All the exported files can be found in the `ECGExport` folder in `on My iPhone` or `iCloud`, depdening on your settings.

## ECG
Inside, you can find a folder called `ECG`. Inside `ECG`, you will find a list of folders, each of which represents an ECG record. These folders are named as the UNIX timestamp of the start date, serving as unique identifier.

```sh
├── ECG
│   ├── 1639486553
│   │   ├── data.csv
│   │   └── metadata.json
│   └── ...
```
In the root folder, you will find two files, `data.csv` and `metadata.json`. `data.csv` contains the raw data extracted. The `timestamp` is in seconds.

### Metadata
Metadata is a JSON-encoded key-value pairs. Here is a table for the metadata keys

> We use `?` to indicate optional. For example, `String?` reads as optional `String`. Optional values can be either represented using `null` or empty string.
>
> Some `String`s are names of enum cases, please refer to the Swift declaration for the cases and description.

| name | type | description | Example |
|------|------|-------------|---------|
| `startDate` | ISO8601 Date | The sample’s start date. | "2021-12-14T12:55:53Z" |
| `endDate` | ISO8601 Date | The sample’s end date. | "2021-12-14T12:56:23Z" |
| `hasUndeterminedDuration` | Bool | Indicates whether the sample has an unknown duration. | false |
| `classification` | [String](https://developer.apple.com/documentation/healthkit/hkelectrocardiogram/classification-swift.enum) | The ECG’s classification. | "sinusRhythm" |
| `averageHeartRate` | Double | The user’s average heart rate during the ECG in beats per minute | 94 |
| `symptomsStatus` | [String](https://developer.apple.com/documentation/healthkit/hkelectrocardiogram/symptomsstatus-swift.enum) | indicates whether the user entered a symptom when they recorded the ECG. | "notSet" |
| `samplingFrequency` | Double | The frequency at which the Apple Watch sampled the voltage in Hz | 511.0390625 |
| `AppleECGAlgorithmVersion` | Int | the version number of the algorithm Apple Watch uses to generate an ECG reading. | 1 |
| `source` | String | The app or device that created this object. | "ECG (com.apple.NanoHeartRhythm)" |
| `lead` | String | Currently always `appleWatchSimilarToLeadI` | "appleWatchSimilarToLeadI" |

