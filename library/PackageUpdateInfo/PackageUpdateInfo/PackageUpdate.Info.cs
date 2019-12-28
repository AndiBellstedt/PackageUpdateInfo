using System;

namespace PackageUpdate {
    /// <summary>
    /// 
    /// </summary>
    public class Info {
        /// <summary>
        /// 
        /// </summary>
        public string Name;

        /// <summary>
        /// 
        /// </summary>
        public string Repository;


        /// <summary>
        /// 
        /// </summary>
        public Version VersionInstalled;

        /// <summary>
        /// 
        /// </summary>
        public Version VersionOnline;

        /// <summary>
        /// 
        /// </summary>
        public bool NeedUpdate;

        /// <summary>
        /// 
        /// </summary>
        public string Path;

        /// <summary>
        /// 
        /// </summary>
        public Uri ProjectUri;

        /// <summary>
        /// 
        /// </summary>
        public Uri IconUri;

        /// <summary>
        /// 
        /// </summary>
        public string ReleaseNotes;

        /// <summary>
        /// 
        /// </summary>
        public bool HasReleaseNotes {
            get {
                if (String.IsNullOrEmpty(ReleaseNotes)) {
                    return false;
                } else {
                    return true;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public bool ReleaseNotesIsUri {
            get {
                if (HasReleaseNotes) {
                    try {
                        Uri urlCheck = new Uri(ReleaseNotes);
                        return true;
                    } catch (Exception) {
                        return false; //could not parse ReleaseNotes to URI
                    }
                } else {
                    return false;
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public string Author;

        /// <summary>
        /// 
        /// </summary>
        public DateTime PublishedDate;

        /// <summary>
        /// 
        /// </summary>
        public string Description;
    }

    /// <summary>
    /// 
    /// </summary>
    public class ReleaseNote {
        /// <summary>
        ///  ModuleName
        /// </summary>
        public string Name;

        /// <summary>
        /// Version of the module
        /// </summary>
        public Version Version;

        /// <summary>
        /// Release note information from the module
        /// </summary>
        public string ReleaseNotes;

        /// <summary>
        /// Boolean that indicates, wether the information in the release notes is a valid url
        /// </summary>
        public bool ReleaseNotesIsURI {
            get {
                if(string.IsNullOrEmpty(ReleaseNotes)) {
                    return false;
                }

                try {
                    Uri _uri = new Uri(ReleaseNotes);
                    return true;
                } catch {
                    return false;
                }
            }
        }

        /// <summary>
        /// URI object from the release notes
        /// </summary>
        public Uri ReleaseNotesURI {
            get {
                if (ReleaseNotesIsURI) {
                    Uri _uri = new Uri(ReleaseNotes);
                    return _uri;
                } else {
                    return null;
                }
            }
        }

        /// <summary>
        /// plain text release note information for the module
        /// </summary>
        public string Notes {
            get {
                if(ReleaseNotesIsURI) {
                    return _notes;
                } else {
                    return ReleaseNotes;
                }
            }

            set {
                _notes = value;
            }
        }

        private string _notes;
    }

    /// <summary>
    /// 
    /// </summary>
    public class Configuration {
        /// <summary>
        /// ModuleNames to exclude from update checking
        /// </summary>
        public string[] ExcludeModuleFromChecking;

        /// <summary>
        /// ModuleNames to include from update checking
        /// </summary>
        public string[] IncludeModuleForChecking;

        /// <summary>
        /// Report when major version changed for a module
        /// </summary>
        public bool ReportChangeOnMajor;

        /// <summary>
        /// Report when minor version changed for a module
        /// </summary>
        public bool ReportChangeOnMinor;

        /// <summary>
        /// Report when build version changed for a module
        /// </summary>
        public bool ReportChangeOnBuild;

        /// <summary>
        /// Report when revision part changed for a module
        /// </summary>
        public bool ReportChangeOnRevision;

        /// <summary>
        /// The minimum interval/timespan has to gone by,for doing a new module update check
        /// </summary>
        public TimeSpan UpdateCheckInterval;

        /// <summary>
        /// Timestamp when last check for update need on modules started
        /// </summary>
        public DateTime LastCheck;

        /// <summary>
        /// Timestamp when last check for update need finished
        /// </summary>
        public DateTime LastSuccessfulCheck;

        /// <summary>
        /// The filepath where to setting file is stored
        /// </summary>
        public string Path;
    }
}
