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

| name | type | description | example value |
|------|------|-------------|---------------|
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


## Heart Rate
Heart rate data exist in a folder next to `ECG`

```sh
├── ECG
├── Heart Rate
│   ├── 2020-3-26.csv
│   └── ...
```

The heart rate data is stored in a flat format internally, meaning it lacks hierarchical structure and resides at the same level. To allow easy access, I grouped these data using its start date.

> Note: 
> Unix `Date` does not store timezone, hence the resulting data *may* be put in a different date. Talk to me and we can look into this.

### Table Keys

Each file is just a CSV table. The metadata is stored along each value.

| name | type | description | example value |
|------|------|-------------|---------------|
| `startDate` | ISO8601 Date | The sample’s start date. | "2021-12-14T12:55:53Z" |
| `endDate` | ISO8601 Date | The sample’s end date. | "2021-12-14T12:56:23Z" |
| `value` | Double | The sample's data in beats per minute | 99.0 |
| `aggregationStyle` | [String](https://developer.apple.com/documentation/healthkit/hkquantityaggregationstyle) | Describes how quantities are aggregated over time. | "discreteTemporallyWeighted" |
| `motionContext` | [String](https://developer.apple.com/documentation/healthkit/hkheartratemotioncontext) | The user’s activity level when the heart rate sample was measured. | "sedentary" | 
| `source` | String | The app or device that created this object. |  |
| `groupIndex` | Int | The identifier of the which to which the sample belongs (read more below) | 0 |

> `groupIndex`:
> `HealthKit` provides heart rate data in two ways: individual data or clusters of data. I presume data are delivered in cluster when they are recorded in a high frequency. To preserve this *clusterness*, I assigned each cluster a different `groupIndex` to differentiate. Talk to me if you want to look into this.


