using System;

namespace PackageUpdate
{
    /// <summary>
    /// 
    /// </summary>
    public class Info
    {
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
                if(String.IsNullOrEmpty(ReleaseNotes)) { return false; } else { return true; }
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
    }
}
